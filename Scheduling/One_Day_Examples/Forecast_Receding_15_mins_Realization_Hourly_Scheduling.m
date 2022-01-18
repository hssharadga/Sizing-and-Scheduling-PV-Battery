
% The forecasted profiles (Load and PV) are updated with receding horizon every  one hour (receding forecasting).
% The forecasting is based on forecasting the hourly profiles while this script is intended to shave the 15-minute peak; forecasting the hourly profile is easier than forecasting the 15-minute profile.
% The Schedule is constructed for one day ahead but also is updated every one-step/one-hour (Receding & Hourly-Based Scheduling). It is updated based on the new forecasted profiles and the new peak Target 
% The Peak Target is updated every 15-mins (15_mins_Realization)

%% To calcuate the day number and 

if mod(day_number,5)~=0
    day_=(floor(day_number/5))*7+mod(day_number,5)+255;
else
    day_=(floor(day_number/5))*7+-2+255;
end 

start=16+1+96*(day_-1);% 4 A.M
endd=16+60+96*(day_-1);% 6 P.M
PV_Power_15=PV_15(start:endd)/1000; % PV_15 is the 15-minute real PV profile
demand_15=Load_15(start:endd)/1000;

%% CVX

global forecasted_Load_daily_matrix_
global forecasted_PV_daily_matrix_;

% cvx_solver SDPT3;

horizon=15;
E0=Cb/2;       % E0 is the energy sotrd in the battery at t=0, in [kwh]
Peak=0;        % Peak Target which is updated every step
Peak_all=[];   % Peak vector
u_receeding=[];
grid_real=[];

for i=1:horizon  % Update the forecasted profiles and the battery schedule every one step (one hour)

horizon_new=horizon-(i-1);

if horizon_new==15
    PV_Forecast0=forecasted_PV_daily_matrix_{horizon_new-2};
    PV_Forecast1=PV_Forecast0(:,PV_day_number);
    PV_Forecast_=[0;0;PV_Forecast1];% Load is 15 hrs while the PV is 13 hrs
elseif horizon_new==14
    PV_Forecast0=forecasted_PV_daily_matrix_{horizon_new-1};
    PV_Forecast1=PV_Forecast0(:,PV_day_number);
    PV_Forecast_=[0;PV_Forecast1];% Load is 14 hrs while the PV is 13 hrs
else
    PV_Forecast0=forecasted_PV_daily_matrix_{horizon_new};
    PV_Forecast_=PV_Forecast0(:,PV_day_number);
end

Load_Forecast0=forecasted_Load_daily_matrix_{horizon_new};
Load_Forecast_=Load_Forecast0(:,day_number);


demand_=Load_Forecast_/1000;% Covert to kW
PV_Power_=PV_Forecast_/1000;


% CVX
L = 1*tril(ones(horizon_new));
cvx_begin quiet
    variable u(horizon_new);
    Es = E0+Cb*L*u;
    grid=demand_+Cb*max(eta*u,u/eta)-N_PV*PV_Power_;
    
    % Objective Function
    minimize sum(max(grid,0))*0.05+7.*max(max(grid),Peak); % Peak is the Peak Target

    subject to
        0<=Es<=Cb;
        u>=control_min;
        u<=control_max;
cvx_end


% Assigning
u_=u;% Convert the convex variable to MATLAB variable

% Updating the battery initial status for the next step
Es = E0+Cb*L*u_;
E0=Es(1);


u_receeding=[u_receeding,u_(1)];% Storing

% Real Grid
u_=repelem(u_,4);
demand__=demand_15(end-(horizon_new*4)+1:end); % for the new horizon
PV_Power__=PV_Power_15(end-(horizon_new*4)+1:end);
 
grid_real=demand__+Cb*max(eta*u_',u_'/eta)-N_PV*PV_Power__';
 
% Realizating the Peak value has been recorded so far in the receding horizon
Peak=max(Peak,max(grid_real(1:4))); % Peak is the new Peak Target (See the objective function) above, (1:4)is explained by the four 15-minute intervals in one hour

Peak_all=[Peak_all,Peak];
  
end


%% Results & Plot
L = 0.25*tril(ones(horizon*4));% 0.25 for the 15-minute peak shaving
x_receeding_15=repelem(u_receeding,4);
E0=Cb/2; % E0 is the energy sotrd in the battery at t=0, in [kwh]
demand_=demand_15;
PV_Power_=PV_Power_15';
grid=demand_'+Cb*max(eta*x_receeding_15,x_receeding_15/eta)-N_PV*PV_Power_';
Es = E0+Cb*L*x_receeding_15';
Peak_all_15=repelem(Peak_all,4);


figure

title_=['Forecast Receding 15-mins-Realization: Shaving = ',num2str(floor((1-(max(grid)/(max(demand_15))))*100)) ,'%'];
title(title_);

yyaxis left
 plot(demand_,'k-')
 hold on
 plot(grid,'g-')
 hold on
 plot(Peak_all_15,'g-.')
 ylabel('[kW]')
yyaxis right
 plot(Es,'r-')
 
ylabel('E_s [kWh]')
xlabel('Time [hr]')
legend('Load','grid energy','Peak','E_s')

xticks(1:8:60)
x__=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];
set(gca,'xticklabel', x__)

shg
x=u_receeding';