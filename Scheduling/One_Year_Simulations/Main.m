
%% one-time calculations
Data_Processing_and_PV_Calculations
Data_Cleaning
%% Inputs and Constants
N_PV=500;                % # PV modules
Cb=450;                  % Battery capacity [kWh]
Es0=Cb;                  % Es0 is the energy sotrd in the battery at t=0, in [kwh]
control_min=-1;          % Charging rate [1/hr]
control_max=0.4;
eta=0.92;                % Charging/discharging efficiency
horizon=15;              % 4am to 6pm
rate_max=7;              % 7 [$/kW]
rate=0.05;               % 0.05 [$/kWh]

%% Methods

Ideal_Year_Shaving         
No_Realization_Hourly_scheduling       % Forecasting the load and PV one-time, i.e, no receding forecasting horizon.
                                       % Then constructing the battery schedule one-time(no receding Scheduling)
                                       % no realization of the peak value
receding_and_hourly_realization_and_scheduling   % Forecasting the load and PV with receding forecasting horizon.
                                                 % Then updating the battery schedule every one hour (receding and hourly-based Scheduling).
                                                 % The peak target is updated every one hour (hourly ralization)
                                                                                                                           
                                          
mins_15_receding_realization_and_scheduling    % Forecasting the load and PV with receding forecasting horizon.
                                               % Then updating the battery schedule every one 15 mins (receding and 15-mins-based Scheduling).
                                               % The peak target is updated every one 15-mins (15-mins ralization)
                                                                                           
Common_Optimal_Strategy
Common_Optimal_Strategy_Day_name_based