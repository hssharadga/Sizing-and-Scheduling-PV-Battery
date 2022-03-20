
# one-time forecasting, receding & 15-mins-based scheduling, 15-mins realization


# Please adjust all addresses that you will find in this code to the current address

##

using SDDP
using Gurobi
const GRB_ENV = Gurobi.Env()
using CSV
using DataFrames
using Tables
using DelimitedFiles

Day_number = 40 # out of 75 days

# To calcuate the day number in the year out of 360
if mod(Day_number, 5) != 0
    day_ = (floor(Int, Day_number / 5)) * 7 + mod(Day_number, 5) + 255
else
    day_ = (floor(Int, Day_number / 5)) * 7 + -2 + 255
end
#to find the PV day number out of 108
PV_day_number = day_ - 252



# Find the index corresponding to the horizon control
horizon_new = 15

sum_ = (horizon_new + 1) * horizon_new / 2; # the last number + first number 
last = sum_
first = last - horizon_new + 1


# Calling the corrections (10 percentiles or 10 scenarios) of the load 
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_Load.csv", DataFrame, header = false);##1
cor = D[:, floor(Int, first):floor(Int, last)]
cor_Load = Matrix(cor)
cor_Load = repeat(cor_Load, inner = (1, 4), outer = (1, 1))

# Calling the corrections (10 percentiles or 10 scenarios) of the PV
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_PV.csv", DataFrame, header = false);##1
cor = D[:, floor(Int, first):floor(Int, last)]
cor_PV = Matrix(cor)
cor_PV = repeat(cor_PV, inner = (1, 4), outer = (1, 1))



# One-time forecasting:

# The forecasted load of a given day and given horizon (one-time forecasting; horizon is fixed and equals 15)
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_Load_daily_matrix_new.csv", DataFrame, header = false);
Load_ = D[Day_number, floor(Int, first):floor(Int, last)]
Load = Vector(Load_)
Load = repeat(Load, inner = (4, 1), outer = (1, 1)) # Covert the hourly profile to 15-mins as the it is 15-mins-based scheduling.
# 10 Scenarios Generation
Load_corr_ = cor_Load .* Load' / 1000
#

# The forecasted PV of a given day and given horizon (one-time forecasting; horizon is fixed and equals 15)
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_PV_daily_matrix_new.csv", DataFrame, header = false);
PV_ = D[PV_day_number, floor(Int, first):floor(Int, last)]
PV = Vector(PV_)
PV = repeat(PV, inner = (4, 1), outer = (1, 1))    # Covert the hourly profile to 15-mins as the it is 15-mins-based scheduling.
# 10 Scenarios Generation
PV_corr_ = cor_PV .* PV' / 1000
#






# Real load and PV (15-mins profiles)

start = 16 + 1 + 96 * (day_ - 1) # 4 A.M
endd = 16 + 60 + 96 * (day_ - 1) # 6 P.M

PV_15_ = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\PV_15.csv", DataFrame, header = false)
Load_15_ = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\Load_15.csv", DataFrame, header = false)

Load_15 = Load_15_[floor(Int, start):floor(Int, endd), 1] / 1000
PV_15 = PV_15_[floor(Int, start):floor(Int, endd), 1] / 1000

demand_ = hcat(Load_15) # 15-mins real profile
PV_Power_ = hcat(PV_15)

# SDDP
model = SDDP.LinearPolicyGraph(
    stages = 15 * 4, # 15-mins-based
    sense = :Min,
    lower_bound = 0.0,
    optimizer = () -> Gurobi.Optimizer(GRB_ENV),
) do sp, t
    set_silent(sp)
    Cb = 450
    NPV = 500
    eta = 0.92
    @variables(sp, begin
        Peak, (SDDP.State, initial_value = 0)
        0 <= Es <= Cb, (SDDP.State, initial_value = Cb)
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
    @stageobjective(sp, 0.05 * grid_pos / 4 + (t == 15 * 4 ? 7 * Peak.out : 0.0))



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
    for i = 1:15*4
],
)

simulations = SDDP.simulate(
    model,
    1,
    [:u, :Peak],
    sampling_scheme = historical_sampler,
)
uu = [simulations[1][i][:u] for i = 1:15*4]

println(uu)

#
Peak_ = [simulations[1][i][:Peak] for i = 1:15*4]


# Peak 
x = Peak_[60]
println(x.out)

# Storing
uu_ = reshape(uu, 1, 15 * 4) # convert vector to matix
CSV.write("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\uu.csv", Tables.table(uu_'), writeheader = false)

##


