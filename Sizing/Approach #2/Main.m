%% Biography
% Authors: Hussein Sharadga(hssharadga@tamu.edu), Dr. Bryan Rasmussen
% Please support my reserch by cite the following related papers:
% A)
% B)
% C)
%%
clc
clear all
%% Electrcity fees
global rate_max
global rate
global eta
rate_max=7; % 7 [$/kW]
rate=0.05; % 0.05 [$/kWh]
eta=0.92; % Charging/discharging Efficiency

%% Loading and one-time calculations
Load_Data_Processing; % Load is the the electrical load
Solar_PV_calculations;

%% Scenario Selection
%(Simulation time differs from scenario to another, see the sizing paper: Section> Scenarios and Approaches Summary)

% #1
% Scenario1;                         %  Simulation time is around 5 minutes with 16 GB RAM
% Scenario1_eta;                     %  Simulation time is around 45 minutes with 16 GB RAM

% #2
Scenario2;                         %  5 minutes 
% Scenario2_eta;                     %  5 minutes
% Scenario2_Adaptive_Pricing;        %  this is one might be slow

% #3
% Scenario3;                         % 5 minutes 
% Scenario3_eta;                     % 35 minutes


%% Energy_Shares  (See Energy Shares section in the sizng paper)
% Energy_Shares