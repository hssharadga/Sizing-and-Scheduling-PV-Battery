function []=Tc_3()% calculate the cell temperature using Sandia Report (Sandia National Laboratories) 

global Ws;
global T_a;

CCC= csvread('POA.csv');
POA=CCC;


% See Equations (11) and (12)and Coefficients Table (Table 1) at the following refernce (Sandia Report):
% King, D. et al, 2004, "Sandia Photovoltaic Array Performance Model", SAND2004-3535, Sandia National Laboratories, Albuquerque, NM. (https://www.osti.gov/servlets/purl/919131)
% Or see PV_LIB Toolbox at "https://pvpmc.sandia.gov/PVLIB_Matlab_Help/" then go to "Example Scripts" then go to "PVL_TestScript1"

a =-3.56;
b =-0.075;
E0=1000;
deltaT=3;
T_m= POA .* (exp(a+b .*Ws )) + T_a;% in deg c
Tcell = T_m + POA./E0.*deltaT;% in deg c

csvwrite("Tcell.csv",Tcell);