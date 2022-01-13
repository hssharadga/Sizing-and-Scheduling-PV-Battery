% Scenario 2 but charging/discharging is ideal (eta=1)
% The PV power provided to grid will be seen as zero thus the optimization algorithm will try its best to utlize it instead of wasting it
  
tic;
global len
global rate_max
global rate
global eta

eta=1;
N=len;
step=4;% step = 1 if the load and PV recorded every 15-minute for 15-minute peak shaving

%% Assume the sizes are given
Cb=  950;
N_PV=3000;

%%
E0=Cb;
L = (step/4)*tril(ones(N));% L unit is hr for both hourly peak shaving and 15-minute peak shaving
cvx_solver MOSEK 
cvx_begin
    variable u(N)
    expression Peak_after_matrix(12)
    Eb = 1000*Cb*u;% Cb is [kWh], u in 1/hr   thus Eb is [W]
    Es = E0+Cb*L*u;
    grid_=Load'+Eb-N_PV*PV';
    grid_=max(grid_,0);% 
   
      % Find the monthly peaks (12 peaks a year)
    step_=(24*30*4/step);% number step (hrs) in one month    
    step_=min(step_,length(grid_));
    j=1;
    for i=1:step_:length(grid_) %the loop is supposed to be of 12 iterations as we have 12 months
        
        Peak_after_matrix(j)=max(grid_(i:i+step_-1));
        j=j+1;
    end
    
    % Objective Function
    minimize (sum(grid_*step/4)/(1000)*rate+rate_max*sum(Peak_after_matrix)/1000)
    
    subject to
    u <= 0.4;
    u >= -1;
    Es <= Cb;
    Es >= 0;
    %Es(end)>=0.99*Cb;
    
 cvx_end

%% Assignment and Time Display
time=toc;
disp(['Time in mins = ',num2str(time/60)])
u=u;

%% Plot the figures
figure
Eb = 1000*Cb*u;% u in 1/hr;
grid_=Load'+Eb-N_PV*PV';
tt = 0:minutes(30):minutes(24.5*60);
t=linspace(0,len-1,len);% start at o and end at 7
tt=t;
yyaxis left
plot(tt,grid_/1000,'g--')
hold on
plot(tt,-Eb'/1000,'r--')
plot(tt,Load/1000,'k-')
plot(tt,N_PV*PV/1000,'b--')
ylabel('kW');
yyaxis right
plot(tt,Es,'r')
xlabel ('time');
ylabel('Battery capacity (Cb)[kWh]');
grid on
title(['Bill amount ', num2str(cvx_optval)])
% xtickformat('hh:mm');
legend('grid contrubtion','battry  contrubtion','Energy Profile','PV power','battery capcity')

