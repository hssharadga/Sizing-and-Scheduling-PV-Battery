% Use this one for hourly peak shaving with  SDDP.jl  and SDDP_2.jl (See "Main" script, then SDDP.jl  and SDDP_2.j)
horizon=15;

global real_daily_matrix_Load_
global real_daily_matrix_PV_;



PV_real_=real_daily_matrix_PV_{horizon-2};
PV_real_given_day_0=PV_real_(:,PV_day_number);
PV_real_given_day_=[0;0;PV_real_given_day_0];
Load_real_=real_daily_matrix_Load_{horizon};
Load_real_given_day_=Load_real_(:,day_number);

L = 1*tril(ones(horizon));

%%  Reading the results obtained by Julia language
% cd 'C:\Users\hssharadga\Desktop\Github\\Scheduling\\One Day Examples SDDP (Julia)' % Update the address to the current address
u=csvread('uu.csv'); % results obtained by Julia language

demand_=Load_real_given_day_/1000;
PV_Power_=PV_real_given_day_/1000;
E0=Cb;
grid=demand_+Cb*max(eta*u,u/eta)-N_PV*PV_Power_;
Es = E0+Cb*L*u;
 
%% To find the peak
 peak=0;
 peak_all=[];
 for i=1:horizon
 
     peak_new=max(peak,grid(i));
     peak_all=[peak_all,peak_new];
     peak=peak_new;
 end
 cost1=sum(max(grid,0))*rate+rate_max.*max((grid));
%%
figure
title_=['SDDP: shaving = ',num2str(((1-(max(grid)/(max(Load_real_given_day_/1000))))*100)) ,'%'];
title(title_);

yyaxis left
 plot(demand_,'k-')
 hold on
 plot(grid,'g-')
 hold on
 plot(N_PV*PV_Power_,'b-')
 ylabel('kW')
 plot(peak_all,'g-.')
 
yyaxis right
 plot(Es,'r-')
 ylabel('kWh')
 xlabel('Time [hr]')
 legend('Load','Grid energy','PV energy','Peak','Es')
%%
xticks(1:2:15)
xx=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];
set(gca,'xticklabel', xx)

xlim([1 15])
grid on
 
shg
