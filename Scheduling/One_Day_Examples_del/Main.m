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

day_number=45;            % We have 75 days for test


%% Calling

Day_number_correction;                % Loading the load and PV profiles  & day number correction

%% Different methods

Ideal                    % Assuming the predcition accurcy is 100%
Forecast                 % Forecasting the load and PV and then constructing the battery schedule using convex optimization
Forecast_Receding
% SDP: Stochastic Dynamic Programming
SDP_Main                 % Consumes about 16 mins
SDP_Simulation           % Forecasting the load and PV and then accounting for the uncertainty then using SDP (Stochastic Dynamic Programming)to constructe the battery schedule
