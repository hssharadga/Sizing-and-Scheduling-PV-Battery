# Sizing and Scheduling Solar Photovoltaic Battery System For Demand Peak-shaving (15-minute monthly demand peak)
     
     
Authors: Hussein Sharadga, Bryan Rasmussen
   
   
**Note**: Should you face an issue running the codes, please feel free to drop a LinkedIn message (https://www.linkedin.com/in/hussein-sharadga/).
    
   
You need to install and import CVX library to your MATLAB (http://cvxr.com/), obtain the licenses (http://cvxr.com/cvx/licensing/). To pair MOSEK solver to CVX and obtain the licenses for MOSEK solver: http://cvxr.com/cvx/doc/mosek.html.
   
Please support my reserch by **cite my PhD dissertation related papers**:
   
A)  Sizing paper.............(Chapter 3): Sizing PV-Battery Grid-Connected System Utilizing the Convex Optimization Algorithm for Peak Shaving   
B)  Scheduling paper.........(Chapter 4): Demand Peak Shaving Using PV-Battery System Under PV Power and Load Prediction-Uncertainty   
C)  Algorithm Selection......(Chapter 6): Comparison of Forecasting Methods for Peak Shaving Control of Site Electrical Demand  
D)  Chapter 5 ....... (DOI: https://doi.org/10.1016/j.renene.2019.12.131)
   
# General Info   
- To procede with any folder, find "Main" MATLAB code.
   
# Info: Sizing Paper


- Approach #2 was used to generate the results of the sizing paper. 
- Approach #1 is very slow for some scenarios in which a lot of binary vectors needs to be optimized. 
- Approach #2 has the full notation and throughly explained, so please start with Approach #2.
- Approach #1, scenario #3 with eta<>1: The formulation was not explained for the sake of brevity in the Sizing paper. The full explanation is now drafted in word files and uploaded in Approach #1 Folder> Sizes-are-given Folder.
- Approach #1, "Main" script notice that J=1 for One-year simulation, J=2 for One-day simulation.
- There are two ways to find the maximum power (MPP) generated by solar PV sysyem:
   1. Sandia's (sandia national laboratories) model as explained in Pmax 4 function. 
   2. Searching algorithm as shown in Other Folder> Maximum-Power-Point-Estimation-PV.  


# Info: Scheduling Paper
- There are two codes for SDP (Stochastic Dynamic Programming):
    1. One written in MATLAB form scratch in our lab which is very slow!
    2. One is advanced, which is based on a library written by researchers in **Julia** language. The library is very fast and based on SDDP (SDDP: Stochastic **Dual** Dynamic Programming).
- For **Julia** SDDP codes, please read the following notes:

     1. Download Julia: https://julialang.org/downloads/
     2. Use VS-Code: https://www.julia-vscode.org
     3. We use the following SDDP library: https://github.com/odow/SDDP.jl 

- Scheduling Folder>> One_Day_Examples_SDDP_Julia Folder:  SDDP.jl has the full notation so please start with it.
- Forecasting is hourly based. ARIMA model is used for forecasting both the PV and electrical load. ARIMA was found to be **stable** to predict the PV generation (see PV_Pred function) with the adopted degrees of integration with MATLAB R2022a, but it is **not stable** with MATLAB R2020b. So you might need to change the degree of integration.
- The sizing work can be applied for any facility. The schduling work here is for school where the control/forecasting horizon is between 4 am and 6 pm. The battery might be charged during this interval (the optimization algorithm will decide about that). The battery is set up on the charging mode after 6 pm till 4 am. The battery will be fully charged at 4 am. The battery is charged slowly to make sure the peak will not occur at the night (the peak in the night is not monteried. However, the school has low load after 6 pm).

# Info: Algorithm Selection
- The following algorithms are covered in  Scheduling Folder> One_Year_Simulations Folder
1) ARIMA-based Scheduling: Differernt timeframes: receding/one-time forecasting, receding/one-time scheduling, realization/no realization.  one-time==non-receding
2) Common Optimal Strategy Scheduling
3) Common Optimal Strategy (Day-name based) Scheduling
- You can code the missing algorithms in the same way: Moving Average, Year Average, Naive Forecasting, Neural Network based Scheduling

