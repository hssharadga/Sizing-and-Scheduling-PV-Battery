function obj = Obj(x)

global len
global count
global Load
global eta
global PV
global rate_max
global rate

%% To show the number of function evaluations
count=count+1;
disp(['Count  ',num2str(count)])
%%

N_PV=x(1);
Cb=x(2);
N=len;
Cb=Cb;
E0=Cb;
step=4;% step = 1 if the load and PV recorded every 15-minute for 15-minute peak shaving
L = (step/4)*tril(ones(N));% L unit is hr for both hourly peak shaving and 15-minute peak shaving

%% CVX

cvx_begin quiet; % quiet is used to prevent displaying  the information of convex iterations
    expression Peak_after_matrix(12)
    variables u(N)
    
    Eb = 1000*Cb*max(1/eta*u,eta*u);% u in 1/hr;
    % Cb is kWh, 1000Cb is Wh,  u is 1/hr, the result is W
    Es = E0+Cb*L*u;% E0 is kWh, Cb is kWh  (u is [1/hour] and L is [1 hour] thus cancel each other)
    grid_=Load'+Eb-N_PV*PV';

    grid_=max(grid_,0);% Scenario 2

    
    step_=(24*30*4/step);% number of month
    step_=min(step_,length(grid_));
    j=1;
    for i=1:step_:length(grid_)
%         if i+step_-1>len
%             maxx(j)=max(grid_(i:end));
%         else    
        Peak_after_matrix(j)=max(grid_(i:i+step_-1));
%         end    
        j=j+1;
    end
    
    L_C_C=LCC(N_PV,Cb,u);
    minimize sum(grid_*step/4)/(1000)*rate+sum(Peak_after_matrix)/1000*rate_max+L_C_C/20

    subject to
    u <= 0.4;
    u >= -1; 
    Es <= Cb;
    Es >= 0;
%     Es(end)>=0.99*Cb;
    
 cvx_end;

u=u';

%  csvwrite("u.csv",u)
%  csvwrite("Es.csv",Es)

%%
Eb=1000*Cb*max(1/eta*u,eta*u);
grid_=Load+Eb-N_PV*PV;
grid_=max(grid_,0);

    
    step_=(24*30*4/step);% number of month
    step_=min(step_,length(grid_));
    j=1;
    Peak_after_matrix=[];
    for i=1:step_:length(grid_)
        
%         if i+step_-1>len
%         
%             maxx(j)=max(grid_contrubtion(i:end));
%         else
        Peak_after_matrix(j)=max(grid_(i:i+step_-1));
%         end    
        j=j+1;
    end
    L_C_C=LCC(N_PV,Cb,u);
    obj =  (rate_max*sum(Peak_after_matrix)/1000+sum(grid_*step/4)/(1000)*rate)+L_C_C/20;
 
%     csvwrite("Peak_after_matrix.csv",Peak_after_matrix)
end