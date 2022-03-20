
E0=Cb; % Initial status of battery

%% To calcuate the day number
if mod(day_number,5)~=0
    day_=(floor(day_number/5))*7+mod(day_number,5)+255;
else
    day_=(floor(day_number/5))*7+-2+255;
end   

%% Reading the charging-rate-vector and calculations
%cd 'C:\Users\hssharadga\Desktop\Github\\Scheduling\\One Day Examples SDDP (Julia)' % Update the address to the current address
u=csvread('uu.csv');% Results obtained by Julia language


% The Battery 15-mins schedule
% length(u)==15, if hourly-based Scheduling (See "Main" script then SDDP.jl, SDDP.j2, SDDP.j3, SDDP.j4), it will retutn a vector of 15 elements as the control horizon for school is between 4 am and 6 pm
% length(u)==60, if 15-mins-based scheduling (See "Main" script then SDDP.j5, SDDP.j6), it will retutn a vector of 60 elements
if length(u)==15
    u=repelem(u,4);% convert the hourly to 15-minute
else
    u=u;
end    


start=16+1+96*(day_-1);% 4 A.M
endd=16+60+96*(day_-1);% 6 P.M

PV_Power_=PV_15(start:endd)/1000;
demand_=Load_15(start:endd)/1000;


L = 0.25*tril(ones(60));% 0.25 because it is 15-minute
grid=demand_+Cb.*max(eta.*u,u/eta)-N_PV.*PV_Power_';
Es = E0+Cb*L*u;
 
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

title_=['SDDP: shaving = ',num2str(floor((1-(max(grid)/(max(demand_))))*100)) ,'%'];
title(title_);

yyaxis left
xj=linspace(1,60,60);
xjj=linspace(2,60,30);
plot(xj,demand_,'k-')
hold on
plot(xj,grid,'g-')
hold on
plot(xjj,N_PV.*PV_Power_(2:2:60),'b-')
ylabel('kW')
plot(xj,peak_all,'g-.')

yyaxis right
plot(xj,Es,'r-')
ylabel('kWh')

xlabel('Time [hr]')
legend('Load','Grid energy','PV energy','Peak','Es') 
%%
xticks(1:8:60)
xx=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];
set(gca,'xticklabel', xx)
grid on
