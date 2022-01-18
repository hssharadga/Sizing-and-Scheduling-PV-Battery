% To plot the forecasting results,  forecasting with receding horizon

%% Input
day_number=30;  % Change this one for different examples
%%
d=day_number;
horizon=15;

%% To find the PV_day_number

% To calcuate the day number in the year out of 360
if mod(day_number,5)~=0
    day_=(floor(day_number/5))*7+mod(day_number,5)+255;
else
    day_=(floor(day_number/5))*7+-2+255;
end 

% To find the PV day number out of 108
PV_day_number=day_-252;


%% Load

Load_real_=real_daily_matrix_Load_{horizon};
Load_Real__=Load_real_(:,d);

figure
plot(Load_Real__/1000,'r--','Linewidth',1.5)
hold on

for i=1:15
Load_Forecast0=forecasted_Load_daily_matrix_{15-i+1};
if i==1
    Load_For__=Load_Forecast0(:,d);
    xx=linspace(i,15,15-i+1)
    plot(xx,Load_For__/1000,'r-','Linewidth',1.5)
else
   Load_For__=Load_Forecast0(:,d);
   xx=linspace(i,15,15-i+1)
   plot(xx,Load_For__/1000) 
end
end

xlabel('Time [hr]')
ylabel('Load [kW]')

xticks(1:2:15)
x=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];
set(gca,'xticklabel', x)

xlim([1 15])
legend('Target')

%% PV

d=PV_day_number
PV_real_=real_daily_matrix_PV_{horizon-2};
PV_real_given_day_0=PV_real_(:,d);
PV_real__=[0;0;PV_real_given_day_0];

figure
plot(PV_real__/1000*N_PV,'r--','Linewidth',1.5)
hold on

for i=1:15
    if i==1
        PV_Forecast0=forecasted_PV_daily_matrix_{(15-i+1)-2};
        PV_Forecast1=PV_Forecast0(:,d);
        PV_Forecast=[0;0;PV_Forecast1];% Load is 15 hours while the PV is 13 hours
    elseif i==2
        PV_Forecast0=forecasted_PV_daily_matrix_{(15-i+1)-1};
        PV_Forecast1=PV_Forecast0(:,d);
        PV_Forecast=[0;PV_Forecast1];% Load is 14 hrs while the PV is 13 hrs
    else
        PV_Forecast0=forecasted_PV_daily_matrix_{(15-i+1)};
        PV_Forecast=PV_Forecast0(:,d);
    end

    if i==1
        xxx=linspace(i,15,15-i+1);
        plot(xxx,PV_Forecast/1000*N_PV,'r-','Linewidth',1.5);
    else
        xxx=linspace(i,15,15-i+1);
        plot(xxx,PV_Forecast/1000*N_PV);
    end    
end

xlabel('Time [hr]')
ylabel('PV Power [kW]')
legend('Target')

xticks(1:2:15)
x=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];
set(gca,'xticklabel', x)

xlim([1 15])

legend('Target')


