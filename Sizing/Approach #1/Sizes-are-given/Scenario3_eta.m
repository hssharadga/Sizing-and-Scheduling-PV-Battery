%% Scenario 3 but charging/discharging is not ideal (eta<>1)

tic;
global len
global rate_max
global rate

M=1000; % Very large number
N=len;
step=4;% step = 1 if the load and PV recorded every 15-minute for 15-minute peak shaving

%% Assume the sizes are given
N_PV=3000;
Cb=950;

%%
E0=Cb;
L = (step/4)*tril(ones(N));
cvx_solver MOSEK
const=(N_PV*PV'-Load')/(1000*Cb);

cvx_begin
    variable u(N)
    variable z1(N)
    variable F1(N)
    variable z2(N)
    variable F2(N)
    variable B0(N) binary
    variable B1(N) binary
    variable B2(N)  binary
    variable B3(N)  binary
    variable B02(N)  binary
    variable B01(N)  binary
    
    expression Peak_after_matrix(12)

    Es = E0+Cb*L*u;
    Eb = (1000*Cb)*(eta*z2+1/eta*z1);
    grid_=Load'-N_PV*PV'+Eb
    
    
      % Find the monthly peaks (12 peaks a year)
    step_=(24*30*4/step);% number step (hrs) in one month    
    step_=min(step_,length(grid_));
    j=1;
    for i=1:step_:length(grid_) %the loop is supposed to be of 12 iterations as we have 12 months
        Peak_after_matrix(j)=max(grid_(i:i+step_-1));
        j=j+1;
    end
    
    % Objective Function
    minimize sum((Load'-N_PV*PV')/1000*(step/4).*(0.04.*B0+0.01)+0.01*(1000*Cb)*(eta*z2+1/eta*z1)/1000*(step/4)+0.04*1000*Cb*(eta*F2+1/eta*F1)/1000*(step/4))+rate_max*sum(Peak_after_matrix)/1000


    subject to
    
    B1<=B2-1+B3.*M
    B1>=B2+1-(1-B3).*M
    u>=-M.*(1-B1)-M.*B2
    u<=M.*B1+M.*(1-B2)
  
    eta*z2+1/eta*z1>=const-M.*(1-B0);
    eta*z2+1/eta*z1<=const+M.*B0;   
    u-z1>=-1+B1
    u-z1<=0.4*(1-B1)

    u-z2>=-1+B2
    u-z2<=0.4*(1-B2)
    
    F1>=-B01
    F1<=0.4*B01
    
    F2>=-B02
    F2<=0.4*B02
    
    z1-F1>=-1*B1+B01
    z1-F1<=0.4*B1-0.4*B01

    z2-F2>=-1*B2+B02
    z2-F2<=0.4*B2-0.4*B02
    
    B02<=B0
    B02<=B2
    B02>=B0+B2-1 
    B01<=B0
    B01<=B1
    B01>=B0+B1-1
    
    Es <= Cb;
    Es >= 0;
    %Es(end)>=0.99*Cap;
cvx_end

%% Assignment and Time Display
time=toc;
disp(['Time in mins = ',num2str(time/60)])
u=u;

%% Plot the figures
figure
time=toc/60;
Eb = 1000*Cb*max(1/eta*u,eta*u);% u in 1/hr;
grid_=Load'+Eb-N_PV*PV';

% changing the time formate
tt = 0:minutes(30):minutes(24.5*60);
t=linspace(0,len-1,len);% start at o and end at 7
tt=t;
yyaxis left
plot(tt,(Load+Eb'-N_PV*PV)/1000,'g--')
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

