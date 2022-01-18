day_number=30;

%% To calcuate the day number
if mod(day_number,5)~=0
    day_=(floor(day_number/5))*7+mod(day_number,5)+255;
else
    day_=(floor(day_number/5))*7+-2+255;
end  
%%

start=16+1+96*(day_-1); % 4 am (15-mins Profile)
endd=16+60+96*(day_-1); % 6 pm
demand_1=Load_15(start:endd)/1000;

start=4+1+24*(day_-1); % 4 am (Hourly Profile)
endd=4+15+24*(day_-1); % 6 pm
demand_2=Load_hourly(start:endd)/1000;

figure
x=2:4:60;
plot(demand_1,'r')
hold on
plot(repelem(demand_2,4),'k-')

legend('15-minutes average','hourly average')
ylabel('Load [kW]')
xlabel('Time [hr]')

xticks(1:8:60)
xx=["4 a.m.","6 a.m.","8 a.m.","10 a.m.","12 p.m.","2 p.m.","4 p.m.", '6 p.m.'];

set(gca,'xticklabel', xx)