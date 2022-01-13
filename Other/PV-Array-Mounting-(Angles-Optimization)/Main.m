% Optimizing the tile and azimuth angles of fixed PV Array to maximize the solar radiation that hits the PV's surface
tic
%% Reading

CC = readtable('Data_Weather.csv'); % we use SAM software to extrace the waether data  (https://sam.nrel.gov/)
CC=CC{:,:};
global DNI
global DHI
global GHI
global zenth; % Sun Angle
global azimuth; % Sun Angle

DNI=CC(:,1);
DHI=CC(:,2);
GHI=CC(:,3);
zenth=CC(:,4);
azimuth=CC(:,5);

%% using gentic algorithm

objective=@ energy_total;
nvars=2;% number of variables 
LB=[0 0];
UB=[90 360];
nonlcon=[];% non linear constraints
[x1,y]= ga(objective,nvars,[],[],[],[],LB,UB,nonlcon);
%% Display

Time=toc;
display (['Time = ',num2str(Time),' second'])
display (['Angles (tilt, azimuth) = ',num2str(x1)])