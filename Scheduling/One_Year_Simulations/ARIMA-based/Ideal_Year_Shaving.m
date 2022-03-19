%% Initializing
Peak=0;
day=0;
Monthly_ideal_Peak=[];
schedule=[];


%%
for i=1:360                                     % 360 days
    
day=day+1                                       % day number
start=16+1+96*(day-1);                          % 4am  (96 is the number of 15-minute periods in a day)
endd=16+60+96*(day-1);                          % 6pm

demand_=Load_Test_15_full(start:endd)/1000;     % Test on the test data
PV_Power_=PV_15(start:endd)/1000;



L = 0.25*tril(ones(horizon*4));                 % 0.25 for the 15-mins

%%  CVX Optimization
cvx_begin quiet
variable u(horizon*4);                                % u is the charging/discharging rate

Es = Es0+Cb*L*u;                                      % Es is energy stored in the battery [kWh]
% Es0 is the energy sotrd in the battery at t=0, in [kwh]. The battery will be fully charged at the 4am every day as we charge it at the night

grid=demand_+Cb*max(eta*u,u/eta)-N_PV*PV_Power_';
minimize sum(max(grid,0))*rate+rate_max.*max((grid)); % max(grid,0): The grid receives the access PV energy for free

subject to
    0<=Es<=Cb;       % Constraints on the battery stored energy
    u>=control_min;  % Constraints on the charging rate  
    u<=control_max;
cvx_end

%% Assigning
u=u;                      % Convert the variable from CVX variable to MATLAB variable

grid=demand_+Cb*max(eta*u,u/eta)-N_PV*PV_Power_';
Peak=max(Peak,max(grid));

if mod(day,30)==0
    Monthly_ideal_Peak=[Monthly_ideal_Peak,Peak];
    Peak=0;
end
schedule=[schedule,u]; % Storing the battery schedules (360 schedules as we have 360 days)

end

% %% Save the results
% csvwrite('C:\Users\hssharadga\Desktop\Spring 2021\One year\Forecast Results\Monthly_ideal_Peak.csv',Monthly_ideal_Peak)
% csvwrite('C:\Users\hssharadga\Desktop\Spring 2021\One year\Forecast Results\schedule2.csv',schedule)








