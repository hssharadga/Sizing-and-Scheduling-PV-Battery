

%% Loading and one-time calculations
Data_Processing_and_PV_Calculations

%% Inputs and Constants
N_PV=500;                % # PV modules
Cb=450;                  % Battery cabacity [kWh]
Es0=Cb;                  % Battery cabacity [kWh]
control_min=-1;          % Charging rate [1/hr]
control_max=0.4;
eta=0.92;                % Charging/discharging efficiency
horizon=15;              % 4am to 6pm
rate_max=7;              % 7 [$/kW]
rate=0.05;               % 0.05 [$/kWh]

%% Methods



Ideal_Year_Shaving