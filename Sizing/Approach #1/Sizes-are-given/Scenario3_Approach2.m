% Scenario 3 but charging/discharging is ideal (eta=1)

tic;% calacute the time required for simulation
global len
global eta
global rate_max
global rate
% global Peak_after_matrix

N=len;
step=4;% step = 1 if the load and PV recorded every 15-minute for 15-minute peak shaving
L = (step/4)*tril(ones(N));% L unit is hr for both hourly peak shaving and 15-minute peak shaving

%% Assume the sizes are given
Cb=  950;
N_PV=3000;
%% CVX solver selection
% cvx_solver SDPT3   % Academic Solver/ Default Solver
cvx_solver MOSEK  % Commercial Solver but free for students, this solver found to be significantly better for the current problem

%% CVX convex optimization
cvx_begin
    expression Peak_after_matrix(12)
    variables Q(N)  grid_neg(N) grid_pos(N);  % grid_pos: grid>0, grid_neg: grid<0, Cb in [kWh]
    E0=Cb; % E0 is the energy sotrd in the battery at t=0, in [kwh]
    Es = E0+L*Q/1000;% E0 is kWh  ( L is 1 hour  Q is watt  L*Q/1000 is kWh)
    grid=Load'-N_PV*PV'+Q;% grid [W]

    % Find the monthly peaks (12 peaks a year)
    step_=(24*30*4/step);% number step (hrs) in one month    
    step_=min(step_,length(grid));
    j=1;
    for i=1:step_:length(grid) %the loop is supposed to be of 12 iterations as we have 12 months
        
        Peak_after_matrix(j)=max(grid(i:i+step_-1));
        j=j+1;
    end
    
    
    % Objective Function
    minimize sum(grid_pos*step/4)/(1000)*rate+(sum(grid_neg*step/4)/(1000)*(-0.01))+rate_max*sum(Peak_after_matrix)/1000
    % grid_pos unit is [W] and it is multiplied by step/4 which is in the unit of [hr]. Thus, grid_pos*step/4 is in the unit of [Wh] then divided by 1000 will be [kWh] which is consistent with the unit of the rate(the rate unit is $/kwh)
    %-0.01 is the refunding rate
    % LCC/20 because the life span is 20 years for the system but the bill amount here is for one year (LCC/20 is the life cycle cost for one year)

    % Constraints
    subject to
    % Constraints on the battery
    Es <= Cb;
    Es >= 0;
    %     Es(end)>=0.99*Cb;% if there is a constraint on the final state 

    % Constraints on the size
    N_PV>=0;% The size is nonnegative
    Cb>=0;% The size is nonnegative
    
    % Constraints on the charging rate   
    Q/1000<=0.4*Cb;
    Q/1000>=-1*Cb;
    
    grid_pos>=grid;
    grid_pos>=0;
    grid_neg>=-grid;
    grid_neg>=0;
    
    grid_pos-grid_neg>=grid;
       
 cvx_end

 
%% Assignment and Time Display
Q=Q;
Cb=Cb;
NPV=N_PV;

time=toc;
disp(['Time in mins = ',num2str(time/60)])


%% Plot the figures
figure
Eb = Q;% u in 1/hr;
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
