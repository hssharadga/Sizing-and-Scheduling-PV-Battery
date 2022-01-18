%% School data Loading
Full=csvread('isd1.csv');

Full=Full(329088:329088+96*365-1);% The Load Profile for one year (365 days) starting 2010 Jan 1 at 12:00 AM (12:00 AM == 00:00 in 24 hr style),
% 96: The data is recorded every 15 minutes; 96 time steps in one day 

Load_0=Full*1000;% Convert from kW to W
Load_15=Load_0(1:end-5*96);% 15-minute profile, -5*96 to exclude the last 5 days; the year will be 360 days

%% Convert the 15-minute profile to hourly average

Load_1 = reshape( Load_15, 4, [] );
Load_hourly = mean( Load_1 ); % Hourly average profile

%% waether data reading 

global DNI;
global DHI;
global GHI;
global zenith;  % Sun angle
global azimuth; % Sun angle
global Ws;      % Wind speed
global T_a;     % Ambient temperature [celsius] 
global len;     % Length of the vector
global AMa;     % Absolute air mass

step2=1;
L1=360*24*2; % %  The solar data is recorderd every 30 minutes (360 days * 24 hours * 2 intervals per hour)
CC = readtable('Data_Weather.csv');
CC=CC{:,:};
DNI=CC(1:step2:L1,1);
DHI=CC(1:step2:L1,2);
GHI=CC(1:step2:L1,3);
zenith=CC(1:step2:L1,4);
azimuth=CC(1:step2:L1,5);
Ws=CC(1:step2:L1,6);  % Wind speed
T_a=CC(1:step2:L1,7); % Ambient temperature
len=length(DNI);
AMa=csvread('AMa.csv');
AMa=AMa(1:step2:L1);

%% PV Calculations
global PV
angles=[25,180]; % The angles of the  PV array are fixed which can be optimized (see GitHub-Folder: Other>PV-Array-Mounting-(Angles-Optimization)), %   [title-angle-of-PV-array  the-azimuth-angle-of-PV-array]
POA_2(angles);
Tc_3();
Pmax_4();
PV=csvread('Pmax.csv');
PV=PV'; % 30-minute PV ptrofile for one year

%% convert the 30-minutes PV to hourly
PV_1 = reshape( PV, 2, [] );
PV_hourly = mean( PV_1 ); % Hourly profile
PV_15=repelem(PV,2);      % 15-minute profile

% %% Saving
% csvwrite('School_Load.csv',Load_hourly)
% csvwrite('Photovolatic.csv',PV_hourly)

%% Cleaning for more efficient training (prediction)

global Load__        % Load hourly profile cleaned for training 
global PV__          % PV   hourly profile cleaned for training

Load_=Load_hourly;   % Load hourly profile before cleaning 
PV_=PV_hourly;       % PV   hourly profile before cleaning 


% A: Remove the first three days from the load; the first day in the new dataset will be Monday
r=1:24*3;
Load_(r)=[];


% B: Remove the weekends
r_=[];
for i=1:51                  % The number of weeks is 51 in a year (year is 360 days)
r=(24*7*i-24*2)+1:24*7*i;   % The last two days in the week is (saturday, sunday) will be removed
r_=[r_,r];
end
Load_(r_)=[];

 
% C: Remove the night hours for (1)Load and (2)PV

% (1)Load
g_=[];
start=4; % 4 A.M
end_= 6; % 6 P.M

for i=1:255 % 255: The number of days without the weekends (51*5=255); the weekends have been removed in B
g1=(24*i-23):24*i-(24-start); % 4 A.M
g2=(24*i-(12-end_-2)):24*i;   % 6 P.M
g=[g1,g2];
g_=[g_,g]; 

end
Load__=Load_;
Load__(g_)=[]; 


% (2)PV
gg_=[];
start=6; % 6 a.m
end_= 6; % 6 P.M

for i=1:360
gg1=(24*i-23):24*i-(24-start); % 6 a.m
gg2=(24*i-(12-end_-2)):24*i;   % 6 P.M
gg=[gg1,gg2];
gg_=[gg_,gg];
end


PV__=PV_;
PV__(gg_)=[];% The PV power between 6 am and 6 pm (without ignoring the weekends, and without ignoring the first 3 days; thus 360 days)


