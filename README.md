# Sizing and Scheduling Solar Photovoltaic Battery System For Demand Peak Shaving (15-minute monthly demand peak)
     
     
Authors: Hussein Sharadga, Dr. Bryan Rasmussen
   
   
**Note**: Should you face an issue **running** the codes, please feel free to drop an E-mail (hssharadga@tamu.edu) or LinkedIn message (Hussein Sharadga).
    
   
You need to install and import CVX library to your MATLAB (http://cvxr.com/), obtain the licenses (http://cvxr.com/cvx/licensing/) and  obtain the licenses for MOSEK solver.
   
Please support my reserch by cite my PhD dissertation  related papers:
   
A)  Sizing paper:    
B)  Scheduling paper:    
C)  Algorithm selection:     
D)  Time series forecasting of solar power generation for large-scale photovoltaic plants (DOI: https://doi.org/10.1016/j.renene.2019.12.131)
   
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
    2. One is addvanced, which is based on a library written by researchers in Julia language. The library is very fast and based on SDDP (SDDP: Stochastic **Dual** Dynamic Programming).
- For Julia SDDP codes, please read the following notes:

     1. Download Julia: https://julialang.org/downloads/
     2. Use VS-Code: https://www.julia-vscode.org
     3. We use the following library: https://github.com/odow/SDDP.jl 


