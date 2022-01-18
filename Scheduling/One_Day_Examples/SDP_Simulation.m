
%% Solving
E0=Cb/2; % E0 is the energy sotrd in the battery at t=0, in [kwh]
[u,Es_all,Peak_all,c,grid]=Trajectories(E0);
% c is the cost


%% Plot
figure
title_=['SDP: Shaving = ',num2str(((1-(Peak_all(end)/(max(Load_real_given_day_/1000))))*100)) ,'%'];
title(title_)

yyaxis left
 plot(Load_real_given_day_/1000,'k-')
 hold on
 plot(grid,'g-')
 hold on
 plot(N_PV*PV_real_given_day_/1000,'b-')
 plot(Peak_all,'g-.')
 ylabel('[kW]')

yyaxis right
 plot(Es_all,'r-')
 
ylabel('E_s [KWh]')
xlabel('Time [hr]')
legend ('Load', 'Grid Energy','PV energy','Peak','E_s')


xticks(1:2:15);
x=["4am","6am","8am","10am","12pm","2pm","4pm", '6pm'];
set(gca,'xticklabel', x);

xlim([1 15]);

