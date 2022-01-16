
cvx_solver SDPT3;
global forecasted_Load_daily_matrix_
global real_daily_matrix_Load_
global forecasted_PV_daily_matrix_;
global real_daily_matrix_PV_;


horizon=15;

PV_real_=real_daily_matrix_PV_{horizon-2};
PV_real_given_day_0=PV_real_(:,PV_day_number);
PV_real_given_day_=[0;0;PV_real_given_day_0];

Load_real_=real_daily_matrix_Load_{horizon};
Load_real_given_day_=Load_real_(:,day_number);

E0=Cb/2; % E0 is the energy sotrd in the battery at t=0, in [kwh]
Peak=0;
Peak_all=[];
x_receeding=[];

for i=1:horizon

% Updating the horizon (receeding horizon)
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

demand_=Load_Forecast_/1000;% kW
PV_Power_=PV_Forecast_/1000;



%% CVX 
L = 1*tril(ones(horizon_new));

cvx_begin quiet

    variable x(horizon_new);
    Es = E0+Cb*L*x;
    grid=demand_+Cb*max(eta*x,x/eta)-N_PV*PV_Power_;
    minimize sum(max(grid,0))*rate+rate_max.*max(max(grid),Peak);% max(max(grid),Peak): Peak is the Target

    subject to
        0<=Es<=Cb;
        x>=control_min;
        x<=control_max;
cvx_end
 

 %% Assigning
 x_=x;
 
 %% Updating the battery status (initial status for the next step)
 Es = E0+Cb*L*x_;
 E0=Es(1);
 
 %% Real grid 
 
 demand_=Load_real_given_day_/1000;
 PV_Power_=PV_real_given_day_/100;
 
 demand_=demand_(end-horizon_new+1:end);
 PV_Power_=PV_Power_(end-horizon_new+1:end);
 
 grid_real=demand_+Cb*max(eta*x_,x_/eta)-N_PV*PV_Power_;
 
 Peak=max(Peak,grid_real(1));                            % Peak will be used as a target for the decision of the next step
 Peak_all=[Peak_all,Peak];
 x_receeding=[x_receeding,x_(1)];
end


 %% Results & Plot

L = 1*tril(ones(horizon));

 E0=Cb/2; % E0 is the energy sotrd in the battery at t=0, in [kwh]
 demand_=Load_real_given_day_/1000;
 PV_Power_=PV_real_given_day_/1000;
 grid=demand_'+Cb*max(eta*x_receeding,x_receeding/eta)-N_PV*PV_Power_';
 Es = E0+Cb*L*x_receeding';

 cost=sum(max(grid,0))*0.05+7.*max((grid));

 figure
 title_=['Forecast Receding: shaving = ',num2str(floor((1-(max(grid)/(max(Load_real_given_day_/1000))))*100)) ,'%'];
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
 legend('Load','Grid energy','Peak','E_s')

 xticks(1:2:15)
 x_=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];
 set(gca,'xticklabel', x_)
 
 xlim([1 15])
 shg
 
 x=x_receeding';