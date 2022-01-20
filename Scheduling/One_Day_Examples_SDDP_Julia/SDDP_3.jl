
# one-time forecasting, receding & hourly-based scheduling, 15-mins realization


##  Block Start
using SDDP
using Gurobi
const GRB_ENV = Gurobi.Env()
using CSV
using DataFrames

Day_number = 45 # out of 75 days

# To calcuate the day number in the year out of 360
if mod(Day_number, 5) != 0
    day_ = (floor(Int, Day_number / 5)) * 7 + mod(Day_number, 5) + 255
else
    day_ = (floor(Int, Day_number / 5)) * 7 + -2 + 255
end
#to find the PV day number out of 108
PV_day_number = day_ - 252



# Read load and PV 15-mins Porfile

start = 16 + 1 + 96 * (day_ - 1) # 4 A.M
endd = 16 + 60 + 96 * (day_ - 1) # 6 P.M

PV_15_ = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\PV_15.csv", DataFrame, header = false)
Load_15_ = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\Load_15.csv", DataFrame, header = false)

Load_15 = Load_15_[floor(Int, start):floor(Int, endd), 1] / 1000
PV_15 = PV_15_[floor(Int, start):floor(Int, endd), 1] / 1000

Load_15_Matrix = hcat(Load_15)
PV_15_Matrix = hcat(PV_15)



Cb = 450
eta_ = 0.92
N_PV_ = 500
u_receding = zeros(1, 15)
recent_Peak = 0  # initial value
recent_Cb = Cb   # initial value

horizon = 15


# Find the index corresponding to the horizon control; See Julia_Inputs MATLAB script for more details

sum_ = (horizon + 1) * horizon / 2; # the last number + first number 
last = sum_
first = last - horizon + 1




# The following commands are Outside the for loop as the forecasting is not receding (one-time forecasting):

################################################
# Calling the corrections (10 percentiles or 10 scenarios) of the load 
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_Load.csv", DataFrame, header = false);##1
cor = D[:, floor(Int, first):floor(Int, last)]
cor_Load = Matrix(cor)

# # Calling the corrections (10 percentiles or 10 scenarios) of the PV
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_PV.csv", DataFrame, header = false);##1
cor = D[:, floor(Int, first):floor(Int, last)]
cor_PV = Matrix(cor)

#  # Calling the forecasted load of a given day and given horizon
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_Load_daily_matrix_new.csv", DataFrame, header = false);
Load_ = D[Day_number, floor(Int, first):floor(Int, last)]
# 10 Scenarios Generation
Load = Vector(Load_)
Load_corr__ = cor_Load .* Load' / 1000
#

#  Calling the forecasted PV of a given day and given horizon
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_PV_daily_matrix_new.csv", DataFrame, header = false);
PV_ = D[PV_day_number, floor(Int, first):floor(Int, last)]
# 10 Scenarios Generation
PV = Vector(PV_)
PV_corr__ = cor_PV .* PV' / 1000

################################################



# For Loop: receding & hourly-based scheduling while it is 15-mins realization, since these are not consistent we train SDDP again every step
for ij = 1:15

    # find the index corresponding to the horizon control
    horizon_new = 15 - (ij) + 1


    sum_ = (horizon_new + 1) * horizon_new / 2# the last number + first number 
    last = sum_
    first = last - horizon_new + 1



    Load_corr_ = Load_corr__[:, end-(horizon_new)+1:end] # Load_corr__  was previously defined outside the For loop
    PV_corr_ = PV_corr__[:, end-(horizon_new)+1:end]     # PV_corr__    was previously defined outside the For loop


    # The real value of the load and PV of a given day and given horizon (horizon is receding)
    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\real_daily_matrix_Load_new.csv", DataFrame, header = false)
    Load_ = D[Day_number, floor(Int, first):floor(Int, last)]
    Load = Vector(Load_)
    demand_ = Load' / 1000

    D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\real_daily_matrix_PV_new.csv", DataFrame, header = false)
    PV_ = D[PV_day_number, floor(Int, first):floor(Int, last)]
    PV = Vector(PV_)
    PV_Power_ = PV' / 1000




    model = SDDP.LinearPolicyGraph(
        stages = horizon_new,
        sense = :Min,
        lower_bound = 0.0,
        optimizer = () -> Gurobi.Optimizer(GRB_ENV),
    ) do sp, t
        set_silent(sp)
        recent_Peak
        recent_Cb
        NPV = N_PV_
        eta = eta_
        @variables(sp, begin
            Peak, (SDDP.State, initial_value = recent_Peak)
            0 <= Es <= Cb, (SDDP.State, initial_value = recent_Cb)
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
            for v in PV_corr_[:, t] for c in Load_corr_[:, t]
        ]
        SDDP.parameterize(sp, support) do ω
            set_normalized_rhs(balance, ω.Load_energy_corr - ω.PV_energy_corr * NPV)
        end
    end


    SDDP.train(model, iteration_limit = 300, print_level = 1)



    historical_sampler = SDDP.Historical(
        [
        (i, (Load_energy_corr = demand_[i], PV_energy_corr = PV_Power_[i])) # demand_== real profile; testing on a real profile means it is receding scheduling
        for i = 1:horizon_new
    ],
    )

    simulations = SDDP.simulate(
        model,
        1,
        [:u, :Peak, :Es, :factor],
        sampling_scheme = historical_sampler,
    )


    uu = [simulations[1][i][:u] for i = 1:horizon_new]

    Peak_ = [simulations[1][i][:Peak] for i = 1:horizon_new]

    Es_ = [simulations[1][i][:Es] for i = 1:horizon_new]
    factor_ = [simulations[1][i][:factor] for i = 1:horizon_new]



    # To find the recent peak

    # 15-mins realization
    uu_15 = repeat(uu, inner = (4, 1), outer = (1, 1))       # repeat the same element 4 times; covert the hourly to 15-mins
    factor_ = repeat(factor_, inner = (4, 1), outer = (1, 1))


    N_PV = N_PV_

    Load_15_Matrix_receding = Load_15_Matrix[end-(horizon_new*4)+1:end]      # 15-mins profile
    PV_15_Matrix_receding = PV_15_Matrix[end-(horizon_new*4)+1:end]          # 15-mins profile


    grid_real = Load_15_Matrix_receding + Cb * factor_ - N_PV * PV_15_Matrix_receding

    xx = maximum(grid_real[1:4])
    recent_Peak = max(recent_Peak, xx)   # The recent peak value, see lines 130, 135



    x = Es_[1]
    recent_Cb = x.out                   # The recent Cb value, see lines 131, 136


    # Storing
    u_receding[ij] = uu[1]

end

println(u_receding)

# Saving  as csv file
uu_ = u_receding
CSV.write("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\uu.csv", Tables.table(uu_'), writeheader = false)


## Block end