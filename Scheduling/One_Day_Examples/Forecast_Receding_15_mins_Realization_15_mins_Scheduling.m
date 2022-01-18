% The battery schedule is updated every 15-mins (15_mins_Scheduling), The peak target is updated every 15-mins (15_mins_Realization), the forcasted profiles are updated every one hour


%% To calcuate the day number 
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
cvx_solver SDPT3;
global forecasted_Load_daily_matrix_
global forecasted_PV_daily_matrix_;

horizon=15;

E0=Cb/2;       % E0 is the energy sotrd in the battery at t=0, in [kwh]
Peak=0;        % Peak Target which is updated every step
Peak_all=[];   % Peak vector
u_receeding=[];
grid_real=[];

PV_Forecast0=forecasted_PV_daily_matrix_{15-2};% Load is 15 hrs while the PV is 13 hrs
PV_Forecast1=PV_Forecast0(:,PV_day_number);
PV_Forecast_=[0;0;PV_Forecast1];

% repelem:  We forecast the hourly average profile as it is easier than forecasting the 15-mins profile
% repelem is used to repeat the hourly value four times as a representation of the 15-mins profile
PV_Forecast_=repelem(PV_Forecast_,4); 


Load_Forecast0=forecasted_Load_daily_matrix_{15};
Load_Forecast_=Load_Forecast0(:,day_number);
Load_Forecast_=repelem(Load_Forecast_,4);

for i=1:horizon*4% horizon = 15 hours      horizon*4 = 15 hours * 4 intervals per hour

horizon_new=horizon*4-(i-1);

demand_=Load_Forecast_(end-(horizon_new)+1:end)/1000;
PV_Power_=PV_Forecast_(end-(horizon_new)+1:end)/1000;

L = 0.25*tril(ones(horizon_new)); % 0.25: 4 intervals per hour

cvx_begin quiet
    variable u(horizon_new);
    Es = E0+Cb*L*u;
    grid=demand_+Cb*max(eta*u,u/eta)-N_PV*PV_Power_;
    minimize sum(max(grid,0))*0.05+7.*max(max(grid),Peak);

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

u_receeding=[u_receeding,u_(1)];

% Real Grid
demand__=demand_15(end-(horizon_new)+1:end);
PV_Power__=PV_Power_15(end-(horizon_new)+1:end);
grid_real=demand__+Cb*max(eta*u_',u_'/eta)-N_PV*PV_Power__';

% Realizating the Peak value has been recorded so far in the receding horizon
Peak=max(Peak,max(grid_real(1)));

Peak_all=[Peak_all,Peak];
 
 
end

%% Results & Plot

L = 0.25*tril(ones(15*4));
E0=Cb/2; % E0 is the energy sotrd in the battery at t=0, in [kwh]
demand_=demand_15;
PV_Power_=PV_Power_15';
grid=demand_'+Cb*max(eta*u_receeding,u_receeding/eta)-N_PV*PV_Power_';
Es = E0+Cb*L*u_receeding';

figure

title_=['Forecast Receding 15-mins Realization 15-mins Scheduling: Shaving = ',num2str(floor((1-(max(grid)/(max(demand_15))))*100)) ,'%'];
title(title_);

yyaxis left
  plot(demand_,'k-')
  hold on
  plot(grid,'g-')
  hold on
  plot(Peak_all,'g-.')
 
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


