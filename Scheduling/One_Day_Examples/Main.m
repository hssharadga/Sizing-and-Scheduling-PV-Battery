global N_PV
global Cb
global horizon
global eta
global control_max
global control_min
global rate_max
global rate

%% One-time Calculation
Loading_and_Cleaning
Training_and_Scenarios_Generation;    % This one consumes around 6 mins. To save time you might run it one time and then save the results as mat file then load it when needed

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

%% Calling
Day_number_correction;          % Loading the load and PV profiles  & day number correction

%% Different methods
% A: Hourly Peak Shaving
Ideal                                     % Assuming the predcition accurcy is 100% (the Load and PV profile are given), the schedule is optimized using convex optimization
Forecast                                  % Forecasting the load and PV (one-time, i.e, no receding forecasting horizon)and then constructing the battery schedule one-time using convex optimization (no realization of the peak value, no receding forecasting and no receding Scheduling)
Forecast_Receding                         % Forecast with receding horizon (Receding Forecasting): the forecasted profiles (Load and PV generation) are updated every one step. The Peak Target is updated every hour (Hourly_Realization). The battery-schedule is updated every hour (Receding & Hourly-Based Scheduling). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SDP: Stochastic Dynamic Programming
SDP_Main                 % Consumes about 16 mins to estimate the future cost

SDP_Simulation           % See comments below
% Forecasting the load and PV and then accounting for the uncertainty by using SDP (Stochastic Dynamic Programming)to constructe the battery schedule
% The schedule is updated every one hour (Receding & Hourly-Based Scheduling) after updating the forecasted profile every one hour (Receding Forecasting)
% and after hourly updating the Peak (Hourly_Realization) the Peak that has been recorded so far
% Other work on SDP is solved in Julia Language

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B: 15-mins Peak Shaving
Ideal_15_mins_Peak_Shaving
Forecast_Receding_15_mins_Realization_Hourly_Scheduling     % Forecast with receding horizon (forecasted profiles are updated hourly )but the Peak Target is updated every 15 mins (15_mins_Realization) as it is intended to shave the 15-mins peak. The battery-schedule is updated hourly (Receding & Hourly-Based Scheduling)
Forecast_Receding_15_mins_Realization_15_mins_Scheduling    % The schedule is updated every 15-mins (Receding & 15-mins-based Scheduling), The peak target is updated every 15-mins (15_mins_Realization), the forcasted profiles are updated every one hour (Receding Forecasting)
Shaving_15_min_using_Forecast_Decision                      % Shaving the 15-mins peak using the decision obtained by Forecast script


%% Other scripts
Receding_Forecasting_Results % Plot the forecasting results for a given day
Hourly_vs_15_mins_profile
