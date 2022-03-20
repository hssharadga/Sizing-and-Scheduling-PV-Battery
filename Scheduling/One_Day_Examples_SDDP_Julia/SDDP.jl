# Note: To Run a Block (Alt+Enter)
# Please adjust all addresses that you will find in this code to the current address

# hourly realization, receding and hourly-based Scheduling, one-time forecasting (no receding)

## Block Start
using SDDP
using Gurobi
const GRB_ENV = Gurobi.Env()
using CSV
using DataFrames
using Tables
using DelimitedFiles


Day_number = 40 # We have 75 days for test. Choose a number betwwen 1-75.


# To calcuate the day number in the year out of 360; See Loading_and_Cleaning MATLAB script for more details
if mod(Day_number, 5) != 0
    day_ = (floor(Int, Day_number / 5)) * 7 + mod(Day_number, 5) + 255
else
    day_ = (floor(Int, Day_number / 5)) * 7 + -2 + 255
end
# To find the PV day number out of 108; See Loading_and_Cleaning MATLAB script for more details
PV_day_number = day_ - 252



# Find the index corresponding to the horizon control; See Julia_Inputs MATLAB script for more details
horizon_new = 15

sum_ = (horizon_new + 1) * horizon_new / 2; # the last number + first number 
last = sum_
first = last - horizon_new + 1

# Calling the corrections (10 percentiles or 10 scenarios) of the load 
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_Load.csv", DataFrame, header = false);      # Please adjust the address to the current address
cor = D[:, floor(Int, first):floor(Int, last)]
cor_Load = Matrix(cor)

# Calling the corrections (10 percentiles or 10 scenarios) of the PV
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\per_PV.csv", DataFrame, header = false);
cor = D[:, floor(Int, first):floor(Int, last)]
cor_PV = Matrix(cor)


# One-time Forecasting: 

# Calling the forecasted load of a given day and given horizon (forecasting horizon=15)
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_Load_daily_matrix_new.csv", DataFrame, header = false);
Load_ = D[Day_number, floor(Int, first):floor(Int, last)]
# 10 Scenarios Generation
Load = Vector(Load_)
Load_corr_ = cor_Load .* Load' / 1000
#


# Calling the forecasted PV of a given day and given horizon (forecasting horizon=15)
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\forecasted_PV_daily_matrix_new.csv", DataFrame, header = false);
PV_ = D[PV_day_number, floor(Int, first):floor(Int, last)]
# 10 Scenarios Generation
PV = Vector(PV_)
PV_corr_ = cor_PV .* PV' / 1000
#






# The real value of the load and PV (hourly profiles)
D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\real_daily_matrix_Load_new.csv", DataFrame, header = false);
Load_ = D[Day_number, floor(Int, first):floor(Int, last)]
Load = Vector(Load_)
demand_ = Load' / 1000

D = CSV.read("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\real_daily_matrix_PV_new.csv", DataFrame, header = false);
PV_ = D[PV_day_number, floor(Int, first):floor(Int, last)]
PV = Vector(PV_)
PV_Power_ = PV' / 1000



# SDDP modeling

model = SDDP.LinearPolicyGraph(
    stages = 15,              # horizon=15; Load is between 4 am and 6 pm.
    sense = :Min,             # minimize the objective function
    lower_bound = 0.0,
    optimizer = () -> Gurobi.Optimizer(GRB_ENV),
) do sp, t
    set_silent(sp)
    Cb = 450               # Battery capacity
    NPV = 500              # # of PV modules
    eta = 0.92             # Charging/Discharging Efficiency
    @variables(sp, begin
        Peak, (SDDP.State, initial_value = 0)
        0 <= Es <= Cb, (SDDP.State, initial_value = Cb)
        grid
        0 <= grid_pos
        -1 <= u <= 0.4    # Charging rate
        factor
    end)
    @constraints(sp, begin
        Peak.out >= Peak.in
        Peak.out >= grid
        Es.out == Es.in + Cb * u
        grid_pos >= grid
        balance, grid - Cb * factor == 0 # grid - Cb factor = Load - PV    >> replace the uncertain value >>     grid - Cb factor = 0
        factor >= eta * u
        factor >= u / eta
    end)
    @stageobjective(sp, 0.05 * grid_pos + (t == 15 ? 7 * Peak.out : 0.0)) ## t == 15 end of horizon; Peak.out is the highest Peak value

    # 0.05 = rate,   7= rate_max


    support = [
        (PV_energy_corr = v, Load_energy_corr = c)
        for v in PV_corr_[:, t] for c in Load_corr_[:, t]  # Scenarios
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
    (i, (Load_energy_corr = demand_[i], PV_energy_corr = PV_Power_[i])) # demand_== real profile; testing on a real profile means it is receding scheduling
    for i = 1:15
],
)

simulations = SDDP.simulate(
    model,
    1,
    [:u, :Peak], # You could also add :Peak, :Es, ...
    sampling_scheme = historical_sampler,
)

# Results
uu = [simulations[1][i][:u] for i = 1:15] # Charging rate
println(uu)

# highest Peak
Peak_ = [simulations[1][i][:Peak] for i = 1:15]
x = Peak_[15]
println(x.out)


# Storing "Charging rate" as it will be processed by MATLAB  
uu_ = reshape(uu, 1, 15)# convert vector to matix
CSV.write("C:\\Users\\hssharadga\\Desktop\\Github\\Scheduling\\One Day Examples SDDP (Julia)\\uu.csv", Tables.table(uu_'), writeheader = false)



## Block End




