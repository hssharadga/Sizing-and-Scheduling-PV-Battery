
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


day_number=45;                  % We have 75 days for test, Change this one for different examples, Choose number between 1-75


Day_number_correction;          % Loading the load and PV profiles  & day number correction


%%
% You need to run any of the following "Julia Codes" before proceeding . Make sure you change the paramters in Julia code to make them consistent with the paramters defined here
% SDDP.jl has the full notation
% SDDP.jl hourly realization, receding and hourly-based Scheduling, one-time forecasting (no receding)
% SDDP_2  hourly realization, receding and hourly-based Scheduling, receding forecasting 

Julia_Results_hourly_Shaving 
% Go to Julia_Results_hourly_Shaving (Line 15) then update the address to the current address 
% Plot the results obtained by (SDDP) written in Julia