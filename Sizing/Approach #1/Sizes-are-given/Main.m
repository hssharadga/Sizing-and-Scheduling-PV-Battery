clc
clear
%% Electrcity fees
global rate_max
global rate
global eta
rate_max=7; %[$/kW]
rate=0.05; % [$/kWh]
eta=0.92; % Charging/Discharging Efficiency


%% See "J" in the these two codes: Load_Data_Processing and Solar_PV_calculations   

J=2; % J=1 One-year simulation, J=2 One-day simulation

%% Loading and one-time calculations
Load_Data_Processing; % Load is the the electrical load
Solar_PV_calculations;

%% Scenario Selection

% See the info about the simulation time in the sizing paper: Section > Scenarios and Approaches Summary)

% #1
% Scenario1;                      %  Simulation time is around 3 minutes for a one year
% Scenario1_eta;                  %  Simulation time might go to infinity for a one year and consume the RAM, try one day to get an idea ! (the simulation time for one day is less than 1 second)
% Scenario1_eta_Approach2;        %  This one to ensure that the results of differernt apprchoses will be the same (the best objective function will be the same but the solution is not unique!)
                                  %  This one consumes around 11 mins for a one year
                                  %  and consumes less than 2 second for one day

% #2
% Scenario2;                      %  3 minutes (Simulation time)for a one year
% Scenario2_eta;                  %  3 minutes (Simulation time)for a one year

% #3
% Scenario3;                      % Simulation time might go to infinity for a one year, try for one day to get an idea ! (the simulation time for one day is less than 3 seconds)
% Scenario3_eta;                  % Simulation time might go to infinity for a one year, try for one day to get an idea ! (the simulation time for one day is less than 1 minute)
% Scenario3_Approach2;            % 3 minutes (Simulation time)for a one year !
 Scenario3_eta_Approach2;        % 12 minutes (Simulation time)for a one year !
