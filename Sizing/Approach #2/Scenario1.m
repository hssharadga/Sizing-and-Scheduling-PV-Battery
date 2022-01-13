% Scenario 1 but charging/discharging is ideal (eta=1)

tic;% calacute the time required for simulation
global len
global eta
global rate_max
global rate
% global Peak_after_matrix
eta=1;
N=len;
step=4;% step = 1 if the load and PV recorded every 15-minute for 15-minute peak shaving
L = (step/4)*tril(ones(N));% L unit is hr for both hourly peak shaving and 15-minute peak shaving

%% CVX solver selection
% cvx_solver SDPT3   % Academic Solver/ Default Solver, this solver is very slow for this problem
cvx_solver MOSEK     % Commercial Solver but free for students, this solver found to be significantly better for the current problem

%% CVX convex optimization
cvx_begin
    expression Peak_after_matrix(12)
    variables Q(N) Cb N_PV;% Cb in [kWh]
    E0=Cb; % E0 is the energy sotrd in the battery at t=0, in [kwh]
    Es = E0+L*Q/1000;% E0 is kWh  ( L is 1 hour  Q is watt  L*Q/1000 is kWh)
    grid_=Load'-N_PV*PV'+Q;% grid_ [W]

    % Find the monthly peaks (12 peaks a year)
    step_=(24*30*4/step);% number step (hrs) in one month    
    step_=min(step_,length(grid_));
    j=1;
    for i=1:step_:length(grid_) %the loop is supposed to be of 12 iterations as we have 12 months
        
        Peak_after_matrix(j)=max(grid_(i:i+step_-1));
        j=j+1;
    end
    
    L_C_C=LCC(N_PV,Cb,Q);% Life cycle cost is function of the (1) sizes (N_PV, Cb) and (2) the charging rate (Q) as Q determines the sizes of the inverter and converter
    
    % Objective Function
    minimize (sum(grid_*step/4)/(1000)*rate+rate_max*sum(Peak_after_matrix)/1000+L_C_C/20)
    % grid_ unit is [W] and it is multiplied by step/4 which is in the unit of [hr]. Thus, grid_*step/4 is in the unit of [Wh] then divided by 1000 will be [kWh] which is consistent with the unit of the rate(the rate unit is $/kwh)
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
    
    % No-supply-to-grid constraint  
    grid_>=0
    
 cvx_end

%% Assignment and Time Display
Q=Q;
Cb=Cb
NPV=N_PV
time=toc;
disp(['Time in mins = ',num2str(time/60)])



