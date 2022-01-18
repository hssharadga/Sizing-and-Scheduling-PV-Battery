
E0=Cb/2;                     % E0 is the energy sotrd in the battery at t=0, in [kwh]
horizon=15;

%% To calcuate the day number
if mod(day_number,5)~=0
    day_=(floor(day_number/5))*7+mod(day_number,5)+255;
else
    day_=(floor(day_number/5))*7+-2+255;
end   

start=16+1+96*(day_-1);
endd=16+60+96*(day_-1);
PV_Power_=PV_15(start:endd)/1000;
demand_=Load_15(start:endd)/1000;

%% CVX
% cvx_solver SDPT3;
cvx_solver MOSEK;
L = 0.25*tril(ones(horizon*4));% 0.25 because it is 15-minute Peak Shaving

cvx_begin
    variable x(horizon*4);
    Es = E0+cb*L*x;
    grid=demand_+cb*max(eta*x,x/eta)-N_PV*PV_Power_';
    grid=max(grid,0)
    minimize sum(grid)*rate+rate_max.*max((grid));
    subject to
        0<=Es<=cb;
        x>=control_min;
        x<=control_max;
cvx_end
%%

u=x;
grid=demand_+cb.*max(eta.*u,u/eta)-N_PV.*PV_Power_';
Es = E0+cb*L*u;
 
%% To find the Peak vector
 peak=0;
 peak_all=[];
 for i=1:60
 
     peak_new=max(peak,grid(i));
     peak_all=[peak_all,peak_new];
     peak=peak_new;
 end
 
%% Results & Plot
 
figure
title_=['Ideal: Shaving = ',num2str(floor((1-(max(grid)/(max(demand_))))*100)) ,'%'];
title(title_);

yyaxis left

xj=linspace(1,60,60);
xjj=linspace(2,60,30);
plot(xj,demand_,'k-')
hold on
plot(xj,grid,'g-')
hold on
plot(xjj,N_PV.*PV_Power_(2:2:60),'b-')
ylabel('[kW]')
plot(peak_all,'g-.')

yyaxis right
 
plot(Es,'r-')
ylabel('E_s[kWh]')
xlabel('Time [hr]')
legend('Load','grid energy','PV energy','Peak','E_s')
 

xticks(1:8:60)
xx=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];
set(gca,'xticklabel', xx)

