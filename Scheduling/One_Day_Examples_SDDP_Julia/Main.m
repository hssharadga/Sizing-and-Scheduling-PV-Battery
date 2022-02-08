
%% One-time Calculation
Loading_and_Cleaning
Training_and_Scenarios_Generation;    % This one consumes around 6 mins. To save time you might run it one time and then save the results as mat file then load it when needed

Julia_Inputs % Preparing the data for Julia

%% Inputs
rate_max=7;        % 7    [$/kW]
rate=0.05;         % 0.05 [$/kWh]
eta=0.92;          % Charging/Discharging Efficiency
N_PV=500;          % # of PV modules
Cb=450;            % Battery capacity
control_max=0.4;   % Maximum u charging rate
control_min=-1;    % Minimum u charging rate
horizon=15;        % The school load is between 4 am and 6 pm

day_number=40;                  % We have 75 days for test, Change this one for different examples, Choose number between 1-75

Day_number_correction;          % Loading the load and PV profiles  & day number correction


%% Run Julia Code
% You need to run any of the following "Julia Codes" before proceeding . Make sure you change the paramters in Julia code to make them consistent with the paramters defined here
% Note: SDDP.jl    has the full notation so please start with it
% Note that all Forecastings are hourly based.
% Do not uncomment this section as these codes need to be run in Julia


% SDDP.jl    hourly realization, receding and hourly-based Scheduling, one-time forecasting (one-time==no receding)
% SDDP_2.jl  hourly realization, receding and hourly-based Scheduling, receding forecasting 

% SDDP_3.jl  15-mins realization, receding & hourly-based Scheduling, one-time forecasting
% SDDP_4.ji  15-mins realization, receding & hourly-based scheduling, receding forecasting 

% SDDP_5.jl  15-mins realization, receding & 15-mins-based scheduling, one-time forecasting
% SDDP_6.jl  15-mins realization, receding & 15-mins-based scheduling, receding forecasting

%% Compare with the ideal case
% Ideal                        % shaving the hourly peak
% Ideal_15_mins_Peak_Shaving   % shaving the 15-mins peak

%%

% Note:
% Go to Results_and_Plot  (Lines 11-13) then update the address to the current address 
% Results_and_Plot_Hourly  (Lines 17-19) then update the address to the current address 
% Note end

Results_and_Plot              % Shaving the 15-mins peak with 6 different techniques
%Results_and_Plot_Hourly      % Use this one for hourly peak shaving, i.e, after running  SDDP.jl  or SDDP_2.jl. Otherwise an error will be returned

