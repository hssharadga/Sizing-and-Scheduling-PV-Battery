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
#Peak_Daily=zeros(360,1)
Peak_recent=0

PV_15_=CSV.read("C:\\Users\\hssharadga\\Desktop\\Spring 2021\\One year\\PV_15.csv",DataFrame,header=false)
Load_15_=CSV.read("C:\\Users\\hssharadga\\Desktop\\Spring 2021\\One year\\Load_15.csv",DataFrame,header=false)

for iji=303:360
Day_number=iji #

println(Day_number)
# find the index corresponding to the horizon control

Cb_recnt=450
Cb_=450
# read load and PV 15 minutes
#
start=16+1+96*(Day_number-1)# 4 A.M
endd=16+60+96*(Day_number-1)# 6 P.M


Load_15=Load_15_[floor(Int,start):floor(Int,endd),1]/1000
#Load_15=Matrix(Load_15)
PV_15=PV_15_[floor(Int,start):floor(Int,endd),1]/1000
#PV_15=Matrix(PV_15)
#

Load_15_Matrix=hcat(Load_15)
PV_15_Matrix=hcat(PV_15)

demand_full=Load_15_Matrix
PV_Power_full=PV_15_Matrix

#

for jj=1:15
horizon_new=15-jj+1
eta_=0.92
NPV_=500
sum_=(horizon_new+1)*horizon_new/2;# the last number + first number 
last=sum_
first=last-horizon_new+1

# Find the corrections of the load
D=CSV.read("C:\\Users\\hssharadga\\Desktop\\SDDP_code\\Final\\per_tot_Load.csv",DataFrame,header=false);##1
cor=D[:,floor(Int,first):floor(Int,last)]
cor_Load=Matrix(cor)
cor_Load=repeat(cor_Load, inner =(1,4), outer = (1,1))

# Find the corrections of the PV
D=CSV.read("C:\\Users\\hssharadga\\Desktop\\SDDP_code\\Final\\per_tot_PV.csv",DataFrame,header=false);##1
cor=D[:,floor(Int,first):floor(Int,last)]
cor_PV=Matrix(cor)
cor_PV=repeat(cor_PV, inner =(1,4), outer = (1,1))

# find the load forecasted of given day and diven horizon
D=CSV.read("C:\\Users\\hssharadga\\Desktop\\Spring 2021\\One year\\forecasted_Load_daily_matrix_new.csv",DataFrame,header=false);

Load_=D[Day_number,floor(Int,first):floor(Int,last)]
Load=Vector(Load_)
Load=repeat(Load, inner =(4,1), outer = (1,1))

Load_corr_=cor_Load.*Load'/1000
#

# find the PV forecasted of given day and diven horizon
D=CSV.read("C:\\Users\\hssharadga\\Desktop\\Spring 2021\\One year\\forecasted_PV_daily_matrix_new.csv",DataFrame,header=false);
PV_=D[Day_number,floor(Int,first):floor(Int,last)]
PV=Vector(PV_)
PV=repeat(PV, inner =(4,1), outer = (1,1))

PV_corr_=cor_PV.*PV'/1000
#



# the real value of the load and PV
#=D=CSV.read("C:\\Users\\hssharadga\\Desktop\\Spring 2021\\One year\\real_daily_matrix_Load_new.csv",DataFrame,header=false);
Load_=D[Day_number,floor(Int,first):floor(Int,last)]
Load=Vector(Load_)
demand_=Load'/1000


D=CSV.read("C:\\Users\\hssharadga\\Desktop\\Spring 2021\\One year\\real_daily_matrix_PV_new.csv",DataFrame,header=false);
PV_=D[Day_number,floor(Int,first):floor(Int,last)]
PV=Vector(PV_)
PV_Power_=PV'/1000=#

#




for kk=1:4
    horizon_new_new=horizon_new*4-kk+1
    demand_=demand_full[end-horizon_new_new+1:end]
    PV_Power_=PV_Power_full[end-horizon_new_new+1:end]

model = SDDP.LinearPolicyGraph(
    stages = horizon_new_new,
    sense = :Min,
    lower_bound = 0.0,
    optimizer = () -> Gurobi.Optimizer(GRB_ENV),
) do sp, t
    set_silent(sp)
    Cb = 450
    NPV = NPV_
    eta = eta_
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
        Es.out == Es.in + Cb * u/4
        grid_pos >= grid
        balance, grid - Cb * factor == 0
        factor >= eta * u
        factor >= u/ eta
    end)
    @stageobjective(sp, 0.05 * grid_pos/4 + (t == horizon_new_new ? 7 * Peak.out : 0.0))
    


    support = [
        (PV_energy_corr = v, Load_energy_corr = c)
        for v in PV_corr_[:, t] for c in Load_corr_[:, t]
    ]
    SDDP.parameterize(sp, support) do ω
        set_normalized_rhs(balance, ω.Load_energy_corr - ω.PV_energy_corr * NPV)
    end
end

SDDP.train(model, iteration_limit = 100, print_level = 0)


#
historical_sampler = SDDP.Historical(
    [
        (i, (Load_energy_corr = demand_[i], PV_energy_corr=PV_Power_[i]))
        for i = 1:horizon_new_new
    ],
)


simulations = SDDP.simulate(
    model,
    1,
    [:u,:Peak,:factor, :Es], # You could also add :Peak, :Es, ...
    sampling_scheme = historical_sampler,
)
uu = [simulations[1][i][:u] for i = 1:horizon_new_new]
factor_ = [simulations[1][i][:factor] for i = 1:horizon_new_new]
Es = [simulations[1][i][:Es] for i = 1:horizon_new_new]
#println(uu)

#
#Peak_ = [simulations[1][i][:Peak] for i = 1:15]
#x=Peak_[15]

#println(x.out)
#println(Peak_Daily)
#Peak_Daily[iji]=x.out

# To find the recent peak
#recent_Peak=x.out

#=uu_15=repeat(uu, inner =(4,1), outer = (1,1))# repeat the same element 4 times
factor_=repeat(factor_, inner =(4,1), outer = (1,1))
x=uu_15=#

x=uu
eta=eta_
N_PV=NPV_
Cb=Cb_
x=Es[1]
Cb_recnt=x.out

grid_real=demand_+Cb*factor_-N_PV*PV_Power_
xx=(grid_real[1])
Peak_recent=max(Peak_recent,xx)
end
end
Peak_Daily[iji]=Peak_recent
Peak_recent=0

CSV.write("C:\\Users\\hssharadga\\Desktop\\Spring 2021\\One year\\reced_forecast_15_minute_realization_schduling_Peak_Daily.csv",  Tables.table(Peak_Daily'), writeheader=false)

end


##
# Monthly Peak

montly_after_peak_matrix=zeros(1,12)
for i=1:12
    montly_after_peak=maximum(Peak_Daily[(i-1)*30+1:i*30]);
    montly_after_peak_matrix[i]=montly_after_peak;
end
println(montly_after_peak_matrix)


matrix_daily_based=reshape(montly_after_peak_matrix,1,12)# convert vector to matix
CSV.write("C:\\Users\\hssharadga\\Desktop\\Spring 2021\\One year\\reced_forecast_15_minute_realization_schduling.csv",  Tables.table(matrix_daily_based'), writeheader=false)

##