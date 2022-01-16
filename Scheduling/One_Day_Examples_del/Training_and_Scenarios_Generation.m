
%% Load
tic
hrs=15;                    % The forecasting horizon for the load between 4 am and 6 pm
global per_Load;           % per = percentiles , percentiles represent the scenarios in this work
per_Load=cell(1,hrs);      % 15 sets is explained by the forecasting with receding horizon

global forecasted_Load_daily_matrix_
global real_daily_matrix_Load_
forecasted_Load_daily_matrix_=cell(1,hrs);
real_daily_matrix_Load_=cell(1,hrs);

for i=1:hrs % Forecasting with Receding horizon
H=i;

global yy          % The real values as one vector 
global forecasted  % The forecasted values as one vector 

[yy,forecasted,forecasted_daily_matrix,real_daily_matrix_Load] = Load_Pred(hrs,H);
forecasted_Load_daily_matrix_{1,i}=forecasted_daily_matrix;
real_daily_matrix_Load_{1,i}=real_daily_matrix_Load;

per1=[];
for j=1: H
    stepp=j;
per= prop(hrs,H,stepp);% prop: Returns percentiles of results
per1=[per1,per'];
end

per_Load{1,i}=per1;       % 10 scenarios at every time step (time-dependant scenarios), i is for every new horizon, i.e., receding horizon.
end




%% PV
hrs=13; % The forecasting horizon for the PV is between 6 am and 6 pm
global per_PV
per_PV=cell(1,hrs+1);
global forecasted_PV_daily_matrix_;
global real_daily_matrix_PV_;
forecasted_PV_daily_matrix_=cell(1,hrs);
real_daily_matrix_PV_=cell(1,hrs);
for i=1:hrs
H=i;
global yy
global forecasted
[yy,forecasted,forecasted_daily_matrix_PV,real_daily_matrix_PV] = PV_Pred(hrs,H);
forecasted_PV_daily_matrix_{1,i}=forecasted_daily_matrix_PV;
real_daily_matrix_PV_{1,i}=real_daily_matrix_PV;
per1=[];
for j=1: H
    stepp=j;
per= prop(hrs,H,stepp);
per1=[per1,per'];
end
per_PV{1,i}=per1;
end

%% PV corrections
% The horizon of the load is between 4 am and 6 pm while the PV horizon is between 6 am and 6 pm. The PV power at 4 am and 5 am are zeros (two corrections)

per_corr=zeros(10,1);                % The first correction
per_PV{1,hrs+1}=[per_corr,per1];

per_corr=zeros(10,2);                % The second correction
per_PV{1,hrs+2}=[per_corr,per1];
%%
time=toc