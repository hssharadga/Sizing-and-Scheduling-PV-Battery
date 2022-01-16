

global forecasted_Load_daily_matrix_
global real_daily_matrix_Load_
global forecasted_PV_daily_matrix_;
global real_daily_matrix_PV_;

horizon=15; % The forecasting horizon for the load between 4 am and 6 pm

%% PV and Load Real Profiles
PV_real_=real_daily_matrix_PV_{horizon-2};
PV_real_given_day_0=PV_real_(:,PV_day_number);
PV_real_given_day_=[0;0;PV_real_given_day_0]; % The forecasting horizon for the PV is between 6 am and 6 pm; the PV power at (4 am) and (5 am) are [0;0].

Load_real_=real_daily_matrix_Load_{horizon};
Load_real_given_day_=Load_real_(:,day_number);

%% PV and Load Forecasted Profiles, which are the inputs to CVX optimization
PV_Forecast0=forecasted_PV_daily_matrix_{horizon-2};
PV_Forecast1=PV_Forecast0(:,PV_day_number);
PV_Forecast=[0;0;PV_Forecast1];% Load is 15 hrs while the PV is 13 hrs

Load_Forecast0=forecasted_Load_daily_matrix_{horizon};
Load_Forecast=Load_Forecast0(:,day_number);


demand_Forecast=Load_Forecast/1000; % Convert to [kW]
PV_Power_Forecast=PV_Forecast/1000; % Convert to [kW]

%% CVX Optimization

cvx_solver SDPT3;
E0=Cb/2; % E0 is the energy sotrd in the battery at t=0, in [kwh]
L = 1*tril(ones(horizon));% L unit is hr for both hourly peak shaving and 15-minute peak shaving
% L = 1/4*tril(ones(horizon));% For 15-minute peak shaving
cvx_begin
    variable u(horizon);

    Es = E0+Cb*L*u;     % Es is the energy sotrd in the battery at t, in [kwh]
    grid_=demand_Forecast+Cb*max(eta*u,u/eta)-N_PV*PV_Power_Forecast;
    
    % Objective Function
    minimize sum(max(grid_,0))*rate+rate_max.*max((grid_));
    
    % Constraints
    subject to
        0<=Es<=Cb;
        u>=control_min;
        u<=control_max;
 
cvx_end
 


 %% A: Assigning and calculating
 u=u;
demand_real=Load_real_given_day_/1000;                % real value
PV_Power_real=PV_real_given_day_/1000;                % real value
grid_=demand_real+Cb*max(eta*u,u/eta)-N_PV*PV_Power_real; % real value
Es = E0+Cb*L*u;
cost=sum(max(grid_,0))*rate+rate_max.*max((grid_));

%% B: Find the Peak Vector : peak_all
 peak=0;
 peak_all=[];
 for i=1:horizon
 
     peak_new=max(peak,grid_(i));
     peak_all=[peak_all,peak_new];
     peak=peak_new;
 end
%% C: Plot
figure

title_=['Forecast: shaving = ',num2str(floor((1-(max(grid_)/(max(Load_real_given_day_/1000))))*100)) ,'%'];
title(title_);

yyaxis left
 plot(demand_real,'k-')
 hold on
 plot(grid_,'g-')
 hold on
 plot(N_PV*PV_Power_real,'b-')
 ylabel('[kW]')
 plot(peak_all,'g-.')
 
yyaxis right
 plot(Es,'r-')
 ylabel('E_s [kWh]')
 xlabel('Time [hr]')
 legend('Load','Grid energy','PV energy','Peak','E_s')

 xticks(1:2:15)
 xx=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];
 set(gca,'xticklabel', xx)

 xlim([1 15])
 grid on
 box on
 shg
 
 csvwrite('Hourly_charging_vector.csv',u)
