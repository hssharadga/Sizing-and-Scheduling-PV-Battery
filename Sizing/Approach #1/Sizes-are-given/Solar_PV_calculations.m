%% global variables
global DNI;
global DHI;
global GHI;
global zenth;% sun angle
global azimuth;% sun angle
global Ws; % wind speed
global T_a; % ambient temperature
global len;
global AMa; % Absolute Air Mass
global PV; 

%% waether data reading 
CC = readtable('Data_Weather.csv'); % we use SAM software to extrace the waether data  (https://sam.nrel.gov/)
CC=CC{:,:};




if J==1
L=24*360; % Number of hours in a year asuming the year is 360 days
else
L=24*1; % One day simulation
end




step2=2;  %  The solar data is recorderd every 30 minutes but the load is per hour in the analysis
L1=L*2;
DNI=CC(1:step2:L1,1);% One-year vector
DHI=CC(1:step2:L1,2);
GHI=CC(1:step2:L1,3);
zenth=CC(1:step2:L1,4);
azimuth=CC(1:step2:L1,5);
Ws=CC(1:step2:L1,6);
T_a=CC(1:step2:L1,7);% in deg c
len=length(DNI);% length of the vector
AMa=csvread('AMa.csv');
AMa=AMa(1:step2:L1);

%% PV Calculations
angles=[25,180]; % The angles of the  PV array are fixed which can be optimized, %   [title-angle-of-PV-array  the-azimuth-angle-of-PV-array]
POA_2(angles);
Tc_3();
Pmax_4();
PV=csvread('Pmax.csv');
PV=PV';






