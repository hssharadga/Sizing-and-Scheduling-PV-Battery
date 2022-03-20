% For more deitals about these symol you might see Solar_PV_calculations.m and Load_Data_Processing.m in the Sizing Folder>> Approach #2

%% Weather data reading and Solar PV calculations
global DNI;
global DHI;
global GHI;
global zenith;
global azimuth;
global Ws;
global T_a;
global len;
global AMa;
global Load;


step2=1;
L1=360*24*2;     % The Weather data is recorderd every 30 minutes

CC = readtable('Data_Weather.csv');
CC=CC{:,:};
DNI=CC(1:step2:L1,1);
DHI=CC(1:step2:L1,2);
GHI=CC(1:step2:L1,3);
zenith=CC(1:step2:L1,4);
azimuth=CC(1:step2:L1,5);
Ws=CC(1:step2:L1,6);
T_a=CC(1:step2:L1,7);
len=length(DNI);
AMa=csvread('AMa.csv');
AMa=AMa(1:step2:L1);

angles=[25,180];
global PV
POA_2(angles);
Tc_3();
Pmax_4();
PV=csvread('Pmax.csv');
PV=PV';

% Convert the 30-minutes PV to hourly profile
PV_1 = reshape( PV, 2, [] );
PV_hourly = mean( PV_1 );

% Convert the 30-minutes PV to 15-mins profile 
PV_15=repelem(PV,2);

% % Saving
% csvwrite('School_Load.csv',Load)
% csvwrite('Photovolatic.csv',PV_hourly)


%% Load Data_Processing

% School data
L_=24*360;
Full=csvread('isd1.csv');     % School
Full1=Full(329088-96*365+96*4:329088-1);     % 96*4 to remove the first 4 holiday days

% Previous Year data (To train ARIMA or Nerual Network (NN))
x=329088-96*365+96*4;
Full2=Full(x-96*365:x-1);

Load_0=Full1*1000;     % Convert from kW to W
Load_2=Full2*1000;

%% Convert the 15-minutes to hourly
Load_15=Load_0(1:end-(1)*96);             % We removed the first 4 holiday days, but still we need to remove the last day. Thus, it will be 360 days.
Load_1 = reshape( Load_15, 4, [] );       % Averaging with window of length 4
Load_ = mean( Load_1 );

Load_2_15=Load_2(1*96+1:end-(4)*96);      % We removed the first one holiday days. Thus we still need to remove the last 4 day. Then it will be 360 days.
Load_2 = reshape( Load_2_15, 4, [] );     % averaging with window of length 4
Load_2 = mean( Load_2 );

Load_=Load_';    % Hourly-average profiles
Load_2=Load_2';

% Hourly profiles
Load_Train=Load_2(1:L_)';
Load_Test=Load_(1:L_)';

% 15-mins profiles
Load_Train_15_full=Load_2_15;
Load_Test_15_full=Load_15;
