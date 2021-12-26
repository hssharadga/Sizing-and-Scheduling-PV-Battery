%%
%%waether data reading 
global DNI;
global DHI;
global GHI;
global zenth;
global azimuth;
global Ws;
global T_a;
global len;
global AMa;
global Load;
global step;


L=24*360
step2=2% since the data is recorderd every 30 minutes while the load is per
L1=L*2
% 15 mins
% step2=1


CC = readtable('Data_Weather.csv');
CC=CC{:,:};
DNI=CC(1:step2:L1,1);
DHI=CC(1:step2:L1,2);
GHI=CC(1:step2:L1,3);
zenth=CC(1:step2:L1,4);
azimuth=CC(1:step2:L1,5);
Ws=CC(1:step2:L1,6);
T_a=CC(1:step2:L1,7);% in deg c
len=length(DNI);
AMa=csvread('AMa.csv');
AMa=AMa(1:step2:L1);

Load=Load_(1:step2:L1);


%% the zise and parameters are given





global angles;
angles=[25,180];
global PV
AOP_2(angles);
Tc_3();
Pmax_4();
PV=csvread('Pmax.csv');
PV=PV';




global rate_max
global rate
rate_max=7;
rate=0.05;

