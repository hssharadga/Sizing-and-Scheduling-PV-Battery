
# 15-mins realization, receding & 15-mins-based scheduling, receding forecasting

##
#using CSV
#using DataFrames

using SDDP
using Gurobi
const GRB_ENV = Gurobi.Env()
using CSV
using DataFrames
using Tables
using DelimitedFiles



Day_number = 40 #
# To calcuate the day number in the year out of 360
if mod(Day_number, 5) != 0
    day_ = (floor(Int, Day_number / 5)) * 7 + mod(Day_number, 5) + 255
else
    day_ = (floor(Int, Day_number / 5)) * 7 + -2 + 255
end
#to find the PV day number out of 108
PV_day_number = day_ - 252


N_PV_ = 500
Cb = 450
Cb_recnt = Cb
Peak_recent = 0

u_receding = zeros(1, 60) # 15-mins-based scheduling, (4 intervals in an hour for 15 hours)


# Read load and PV 15 minutes
start = 16 + 1 + 96 * (day_ - 1) # 4 A.M
endd = 16 + 60 + 96 * (day_ - 1) # 6 P.M

PV_15_ = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\PV_15.csv", DataFrame, header = false)
Load_15_ = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\Load_15.csv", DataFrame, header = false)


Load_15 = Load_15_[floor(Int, start):floor(Int, endd), 1] / 1000
PV_15 = PV_15_[floor(Int, start):floor(Int, endd), 1] / 1000

Load_15_Matrix = hcat(Load_15)
PV_15_Matrix = hcat(PV_15)

demand_full = Load_15_Matrix
PV_Power_full = PV_15_Matrix

#


ji = 0

for jj = 1:15                   #  receding forecasting (hourly-based; thus 15 iterations)
    horizon_new = 15 - jj + 1



    sum_ = (horizon_new + 1) * horizon_new / 2   # the last number + first number 
    last = sum_
    first = last - horizon_new + 1

    # Calling the corrections (10 percentiles or 10 scenarios) of the load 
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_Load.csv", DataFrame, header = false)##1
    cor = D[:, floor(Int, first):floor(Int, last)]
    cor_Load = Matrix(cor)
    cor_Load = repeat(cor_Load, inner = (1, 4), outer = (1, 1)) # repeat the scenarios 4 times (Convert the hourly to 15-mins)

    # Calling the corrections (10 percentiles or 10 scenarios) of the PV
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_PV.csv", DataFrame, header = false)##1
    cor = D[:, floor(Int, first):floor(Int, last)]
    cor_PV = Matrix(cor)
    cor_PV = repeat(cor_PV, inner = (1, 4), outer = (1, 1))    # repeat the scenarios 4 times (Convert the hourly to 15-mins)


    #  The forecasted load  of a given day and given horizon (horizon is receding)
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_Load_daily_matrix_new.csv", DataFrame, header = false)

    Load_ = D[Day_number, floor(Int, first):floor(Int, last)]
    Load = Vector(Load_)
    Load = repeat(Load, inner = (4, 1), outer = (1, 1))  # repeat the forecasted value 4 times (Convert the hourly to 15-mins)
    # 10 Scenarios Generation
    Load_corr_ = cor_Load .* Load' / 1000
    #

    # The forecasted PV  of given day and given horizon (horizon is receding)
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_PV_daily_matrix_new.csv", DataFrame, header = false)
    PV_ = D[PV_day_number, floor(Int, first):floor(Int, last)]
    PV = Vector(PV_)
    PV = repeat(PV, inner = (4, 1), outer = (1, 1)) # repeat the forecasted value 4 times (Convert the hourly to 15-mins)
    # 10 Scenarios Generation
    PV_corr_ = cor_PV .* PV' / 1000
    #


    for kk = 1:4  # 15-mins-based scheduling  (4 interval in hour)
        ji = ji + 1
        horizon_new_new = horizon_new * 4 - kk + 1
        # real value updated as the horizon is receding
        demand_ = demand_full[end-horizon_new_new+1:end]
        PV_Power_ = PV_Power_full[end-horizon_new_new+1:end]

        model = SDDP.LinearPolicyGraph(
            stages = horizon_new_new,
            sense = :Min,
            lower_bound = 0.0,
            optimizer = () -> Gurobi.Optimizer(GRB_ENV),
        ) do sp, t
            set_silent(sp)
            Cb = 450
            eta = 0.92
            NPV = N_PV_
            Cb_recnt
            Peak_recent
            @variables(sp, begin
                Peak, (SDDP.State, initial_value = Peak_recent)
                0 <= Es <= Cb, (SDDP.State, initial_value = Cb_recnt)
                grid
                0 <= grid_pos
                -1 <= u <= 0.4
                factor
            end)
            @constraints(sp, begin
                Peak.out >= Peak.in
                Peak.out >= grid
                Es.out == Es.in + Cb * u / 4
                grid_pos >= grid
                balance, grid - Cb * factor == 0
                factor >= eta * u
                factor >= u / eta
            end)
            @stageobjective(sp, 0.05 * grid_pos / 4 + (t == horizon_new_new ? 7 * Peak.out : 0.0)) # "grid_pos / 4" divided by 4  to convert from 15-mins to hourly



            support = [
                (PV_energy_corr = v, Load_energy_corr = c)
                for v in PV_corr_[:, t] for c in Load_corr_[:, t]
            ]
            SDDP.parameterize(sp, support) do ω
                set_normalized_rhs(balance, ω.Load_energy_corr - ω.PV_energy_corr * NPV)
            end
        end


        # Train
        SDDP.train(model, iteration_limit = 100, print_level = 1)


        # Test
        historical_sampler = SDDP.Historical(
            [
            (i, (Load_energy_corr = demand_[i], PV_energy_corr = PV_Power_[i])) # demand_== real profile; testing on the real profile means it is receding scheduling
            for i = 1:horizon_new_new
        ],
        )

        simulations = SDDP.simulate(
            model,
            1,
            [:u, :Peak, :factor, :Es],
            sampling_scheme = historical_sampler,
        )


        uu = [simulations[1][i][:u] for i = 1:horizon_new_new]
        factor_ = [simulations[1][i][:factor] for i = 1:horizon_new_new]
        Es = [simulations[1][i][:Es] for i = 1:horizon_new_new]



        x = Es[1]
        Cb_recnt = x.out                     # update for the next step, see line 109, 113

        N_PV = N_PV_
        grid_real = demand_ + Cb * factor_ - N_PV * PV_Power_
        xx = (grid_real[1])
        Peak_recent = max(Peak_recent, xx)    # update for the next step, see line 110, 112

        # Storing 
        u_receding[ji] = uu[1]
    end
end

println(u_receding)

# Saving  as csv file
uu_ = u_receding
CSV.write("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\uu.csv", Tables.table(uu_'), writeheader = false)



##
