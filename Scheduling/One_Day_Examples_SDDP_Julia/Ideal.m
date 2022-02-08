
% Real profiles
demand_=Load_real_given_day_/1000;
PV_Power_=PV_real_given_day_/1000;

%% CVX Optimization
% cvx_solver SDPT3;
% cvx_solver MOSEK;

E0=Cb;                     % E0 is the energy sotrd in the battery at t=0, in [kwh]
L = 1*tril(ones(horizon));   % L unit is hr for both hourly peak shaving and 15-minute peak shaving
                             % L = 1/4*tril(ones(horizon));% For 15-minute peak shaving

cvx_begin
    variable u(horizon);

    Es = E0+Cb*L*u;
    grid=demand_+Cb*max(eta*u,u/eta)-N_PV*PV_Power_;
    grid=max(grid,0)
    minimize sum(grid)*rate+rate_max.*max((grid));

    subject to
        0<=Es<=Cb;
        u>=control_min;
        u<=control_max;
cvx_end

%% Results and Plot
 
grid=demand_+Cb*max(eta*u,u/eta)-N_PV*PV_Power_;% for correction

figure
title_=['Ideal: Shaving = ',num2str(floor((1-(max(grid)/(max(Load_real_given_day_/1000))))*100)) ,'%'];
title(title_);

yyaxis left
 xxx=linspace(1,15,15);
 plot(xxx,demand_,'k-')
 hold on
 plot(xxx,grid,'g-')
 plot(N_PV*PV_Power_,'b-')
 
% Find the Peak Vector : peak_all
 peak=0;
 peak_all=[];
 for i=1:horizon
 
     peak_new=max(peak,grid(i));
     peak_all=[peak_all,peak_new];
     peak=peak_new;
 end
plot(xxx,peak_all,'g-.')

ylabel('[kW]')
 
yyaxis right
    plot(xxx,Es,'r-')
    
legend('Load','Grid energy','PV energy','Peak','E_s')
ylabel('E_s[kWh]')
xlabel('Time [hr]')

xticks(1:2:15)
x=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];
set(gca,'xticklabel', x)

xlim([1 15])

grid on

shg


