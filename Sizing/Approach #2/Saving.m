%% Plot and  figures

global rate_max
global rate 

%% Without Shaving Peaks and bill

step_=(24*30);% Number of hours in one month
step_=min(step_,length(Load));
j=1;
for i=1:step_:length(Load)% the loop is supposed to be of 12 iterations as we have 12 months

    Peak_before_matrix(j)=max(Load(i:i+step_-1));
    j=j+1;
end

Peak_sum=sum(Peak_before_matrix)/1000; % Convert to kW
Peak_fees=Peak_sum*rate_max% The fees on the 12 peaks in the year, rate_max is the unit of [$/kW]
step=4;% step = 1 if the load and PV recorded every 15-minute for 15-minute peak shaving, step = 4 for hourly peak shaving 
Consumption_fees=sum(Load)/1000 *(step/4)*rate % the consumption, the rate is in unit of [$/ kWh], sum(Load)/1000 *(step/4) is in the unit of [kWh]
Bill_before=Peak_fees+Consumption_fees

%% Plot
u=Q/1000/Cb;% u is in the unit of [1/hr], Q/1000 = [kW], Cb =[kWh], Q/1000/Cb = [kW]/[kWh]= [1/h]
Eb = 1000*Cb*max(1/eta*u,eta*u);% Eb is the battery energy [W], Cb in [kwh], u in 1/hr;
grid_=Load'+Eb-NPV*PV';

% Changing the time formate
% tt = 0:minutes(30):minutes(24.5*60);
t=linspace(0,len-1,len);% start at o and end at 7
figure
tt=t;
yyaxis left
plot(tt,grid_/1000,'g--')
hold on
plot(tt,-Eb'/1000,'r--')
plot(tt,Load/1000,'k-')
plot(tt,N_PV*PV/1000,'b--')
ylabel('Power [kW]');
yyaxis right
plot(tt,Es,'r')
xlabel ('time [hr]');
ylabel('Battery capacity (Cb)[kWh]');
grid on
LCC_one_year=floor(LCC(NPV,Cb,Q)/20);

bill_amount=floor(cvx_optval-LCC_one_year);% CVX_optval is the optimal solution obtained by CVX Optimization
                                           % CVX_optval is the electcity cost = bill_amount + Life_cycle_cost of one year
title(['Bill amount: ', '$ ',num2str(floor(bill_amount)), ' LCC: ', '$ ',num2str(LCC_one_year) ])
% xtickformat('hh:mm');
legend('grid contrubtion','battry  contrubtion','Energy Profile','PV power','battery capcity')

%% Saving and others
bill_amount=floor(cvx_optval-LCC_one_year);% CVX_optval is the optimal solution obtained by CVX Optimization
                                           % CVX_optval is the electcity cost = bill_amount + Life_cycle_cost of one year
                                          
shaving=(sum(Peak_before_matrix)-sum(Peak_after_matrix))/1000; % to kW
shaving_dollar=shaving*rate_max% in $
step=4;% step = 1 if the load and PV recorded every 15-minute for 15-minute peak shaving
PV_money=sum(PV)*NPV/1000*step/4*rate; % sum(PV)*NPV/1000*step/4 is in [kWh]
L_C_C=LCC(NPV,Cb,Q)/20; % in $

global PV_LCC
global Cb_LCC
PV_LCC_=floor(PV_LCC/20);% Life cycle cost of PV
cb_LCC_=(Cb_LCC/20)

Loss=-(sum(grid_(grid_<0))*step/4/1000)*rate% PV power provided to the gird for free in [kWh]

Electricity_Cost_Reduction_Percentage=(1-(cvx_optval/Bill_before))*100%


