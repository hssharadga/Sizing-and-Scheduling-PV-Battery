clc
clear 
global G
global T
global Ns
global Np

%%  Note:

% The parameters in the manufacturer datasheet are given for one module (Ns=1, Np=1), thus to calculate the other varaibles at standered condtion (the varaibles are Ipvn, Ion, Rs, Rshn, n), we assume (Ns=1, Np=1). 
% Also to calculate those varaibles at the different weather condtions (G,T), we assume (Ns=1, Np=1).
% The effect of Ns and Np will be only applied on the (I-V) equation  which is written in term of lambert w function.

%% 1: Standard_Conditions & One-PV-Module

Standard_Conditions; % To find the paramters at the standered conditions (standered conditions are G=1000, T=25) where T is the cell temperature

%% 2: Maximum power generated by one PV module at different operating conditions
% Note: Do not run this one before the script (Standard_Conditions)

G=900;
T=25;
[Pmax_One_Module,Vmax_One_Module]=PV_Maximum_Power_One_Module(G,T) 

%% 3: Maximum power generated by  PV Array at different operating conditions (Searching Method)
% Note: Do not run this one before the script (Standard_Conditions)

G=800;
T=40;
Ns=3; % Number of PV modules connected in series in an array
Np=2; % Number of PV modules  connected in parallel in an array
Array;
%% 4: Maximum power generated by  PV Array at different operating conditions (Using the linear relations: See Section> PV Array Configuration, Sizing Paper)
% Note: Do not run this one before the script (Standard_Conditions)

G=800;
T=40;
Ns=3; % Number of PV modules connected in series in an array
Np=2; % Number of PV modules  connected in parallel in an array
Npv=Ns*Np; % Total PV modules
[Pmax_One_Module,Vmax_One_Module]=PV_Maximum_Power_One_Module(G,T);% One PV Module 
Pmax_array=Pmax_One_Module*Npv % Maximum power generated by  PV Array
Vmax_array=Vmax_One_Module*Ns  % Voltage at the Maximum power point