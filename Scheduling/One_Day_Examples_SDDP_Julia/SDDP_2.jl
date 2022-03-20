
# hourly realization, receding and hourly-based Scheduling, receding forecasting
# receding forecasting: 
# (1) The forecasted profile are updated every one step
# (2) The scenarios are also updated for the new horizon, thus SDDP needs to be trained again for every step

# Please adjust all addresses that you will find in this code to the current address

##

using SDDP
using Gurobi
const GRB_ENV = Gurobi.Env()
using CSV
using DataFrames


Day_number = 40


if mod(Day_number, 5) != 0
    day_ = (floor(Int, Day_number / 5)) * 7 + mod(Day_number, 5) + 255
else
    day_ = (floor(Int, Day_number / 5)) * 7 + -2 + 255
end

PV_day_number = day_ - 252


# Read load and PV 15-mins profile

start = 16 + 1 + 96 * (day_ - 1) # 4 A.M
endd = 16 + 60 + 96 * (day_ - 1) # 6 P.M

PV_15_ = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\PV_15.csv", DataFrame, header = false) 
Load_15_ = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\Load_15.csv", DataFrame, header = false)

Load_15 = Load_15_[floor(Int, start):floor(Int, endd), 1] / 1000
PV_15 = PV_15_[floor(Int, start):floor(Int, endd), 1] / 1000





Cb = 450
u_receding = zeros(1, 15)
recent_Peak = 0
recent_Cb = Cb


for ij = 1:15 # Updating the forecasted value (receding forecasting) and accordingly the scenarios

    # find the index corresponding to the horizon control; See Julia_Inputs MATLAB script for more details
    horizon_new = 15 - (ij) + 1

    sum_ = (horizon_new + 1) * horizon_new / 2# the last number + first number 
    last = sum_
    first = last - horizon_new + 1

    # Calling the corrections (10 percentiles or 10 scenarios) of the load 
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_Load.csv", DataFrame, header = false)##1
    cor = D[:, floor(Int, first):floor(Int, last)]
    cor_Load = Matrix(cor)

    # Calling the corrections (10 percentiles or 10 scenarios) of the PV
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_PV.csv", DataFrame, header = false)##1
    cor = D[:, floor(Int, first):floor(Int, last)]
    cor_PV = Matrix(cor)

    # Calling the forecasted load of a given day and given horizon (forecasting horizon is receding)
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_Load_daily_matrix_new.csv", DataFrame, header = false)
    Load_ = D[Day_number, floor(Int, first):floor(Int, last)]
    # 10 Scenarios Generation
    Load = Vector(Load_)
    Load_corr_ = cor_Load .* Load' / 1000
    #

    # Calling the forecasted PV of a given day and given horizon (forecasting horizon is receding)
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_PV_daily_matrix_new.csv", DataFrame, header = false)
    PV_ = D[PV_day_number, floor(Int, first):floor(Int, last)]
    # 10 Scenarios Generation
    PV = Vector(PV_)
    PV_corr_ = cor_PV .* PV' / 1000
    #

    # The real value of the load and PV of a given day and given horizon  (horizon is receding) (hourly profiles)
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\real_daily_matrix_Load_new.csv", DataFrame, header = false)
    Load_ = D[Day_number, floor(Int, first):floor(Int, last)]
    Load = Vector(Load_)
    demand_ = Load' / 1000


    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\real_daily_matrix_PV_new.csv", DataFrame, header = false)
    PV_ = D[PV_day_number, floor(Int, first):floor(Int, last)]
    PV = Vector(PV_)
    PV_Power_ = PV' / 1000


    # SDDP modeling
    model = SDDP.LinearPolicyGraph(
        stages = horizon_new,
        sense = :Min,
        lower_bound = 0.0,
        optimizer = () -> Gurobi.Optimizer(GRB_ENV),
    ) do sp, t
        set_silent(sp)
        recent_Peak     # updated every step, See lines 171, 174
        recent_Cb       # updated every step, See lines 171, 174
        NPV = 500
        eta = 0.92
        @variables(sp, begin
            Peak, (SDDP.State, initial_value = recent_Peak)        # recent_Peak: updated every step
            0 <= Es <= Cb, (SDDP.State, initial_value = recent_Cb) # recent_Cb: updated every step
            grid
            0 <= grid_pos
            -1 <= u <= 0.4
            factor
        end)
        @constraints(sp, begin
            Peak.out >= Peak.in
            Peak.out >= grid
            Es.out == Es.in + Cb * u
            grid_pos >= grid
            balance, grid - Cb * factor == 0
            factor >= eta * u
            factor >= u / eta
        end)
        @stageobjective(sp, 0.05 * grid_pos + (t == horizon_new ? 7 * Peak.out : 0.0))



        support = [
            (PV_energy_corr = v, Load_energy_corr = c)
            for v in PV_corr_[:, t] for c in Load_corr_[:, t]  # PV_corr_ is different for different horizon (horizon is receding)
        ]
        SDDP.parameterize(sp, support) do ω
            set_normalized_rhs(balance, ω.Load_energy_corr - ω.PV_energy_corr * NPV)
        end
    end

    # Train
    SDDP.train(model, iteration_limit = 300, print_level = 1)


    # Test
    historical_sampler = SDDP.Historical(
        [
        (i, (Load_energy_corr = demand_[i], PV_energy_corr = PV_Power_[i]))
        for i = 1:horizon_new
    ],
    )
    simulations = SDDP.simulate(
        model,
        1,
        [:u, :Peak, :Es],
        sampling_scheme = historical_sampler,
    )


    uu = [simulations[1][i][:u] for i = 1:horizon_new]

    Peak_ = [simulations[1][i][:Peak] for i = 1:horizon_new]

    Es_ = [simulations[1][i][:Es] for i = 1:horizon_new]



    # updated every step (realization of the recent peak):


    x = Peak_[1]
    recent_Peak = x.out     # updated every step,   See line 106, 107, 111 and 112

    x = Es_[1]
    recent_Cb = x.out       # updated every step,   See line 106, 107, 111 and 112

    u_receding[ij] = uu[1]  # Storing the charging rate

end

println(u_receding)

uu_ = u_receding

CSV.write("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\uu.csv", Tables.table(uu_'), writeheader = false)

##
