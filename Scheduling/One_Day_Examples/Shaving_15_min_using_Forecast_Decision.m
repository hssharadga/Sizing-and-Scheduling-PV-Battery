% Shaving the 15-mins peak using the decision obtained by Forecast scripts (optimized hourly charging rate vector with no realization and no receding horizon (for both forecasting and scheduling))

%% To calcuate the day number
if mod(day_number,5)~=0
    day_=(floor(day_number/5))*7+mod(day_number,5)+255;
else
    day_=(floor(day_number/5))*7+-2+255;
end   

%% Reading the hourly-charging-rate-vector obtained by Forecast scripts 
u=csvread('Hourly_charging_vector.csv');
u=u;

u=repelem(u,4);% convert the hourly to 15-minute

start=16+1+96*(day_-1);% 4 A.M
endd=16+60+96*(day_-1);% 6 P.M
PV_Power_=PV_15(start:endd)/1000;
demand_=Load_15(start:endd)/1000;

grid=demand_+cb.*max(eta.*u,u/eta)-N_PV.*PV_Power_';
L = 0.25*tril(ones(60));% 0.25 b/c it is 15-minute
Es = E0+cb*L*u;

%% To find the peak
 peak=0;
 peak_all=[];
 for i=1:60
 
     peak_new=max(peak,grid(i));
     peak_all=[peak_all,peak_new];
     peak=peak_new;
 end
 
%% Plot
figure
title_=['Forecast: shaving = ',num2str(floor((1-(max(grid)/(max(demand_))))*100)) ,'%'];
title(title_);

yyaxis left

 xj=linspace(1,60,60);
 xjj=linspace(2,60,30);
 plot(xj,demand_,'k-')
 hold on
 plot(grid,'g-')
 hold on
 plot(xjj,N_PV.*PV_Power_(2:2:60),'b-')
 ylabel('kW')
 plot(xj,peak_all,'g-.')
 
yyaxis right
 plot(xj,Es,'r-')
 
 ylabel('kWh')
 xlabel('Time [hr]')
 
legend('Load','Grid energy','PV energy','Peak','Es')

 
xticks(1:8:60)
xx=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];

set(gca,'xticklabel', xx)

