
% Training & Prediction_Results

function [yy,forecasted,forecasted_daily_matrix_PV,real_daily_matrix_PV] = PV_Pred(hrs,H)

global PV__
Load_=PV__';

All=length(Load_); % 360 day : 252 for traning and 108 for testing. One day is 13 values as the PV power is between 6 am and 6 pm
T=floor (0.7*All);
delta_T=rem(T,hrs);
T=T-delta_T;


%  Degree of ARIMA
degree=2;
if H==8||H==3
degree=1;
end
if H==9
degree=3;
end

past_data=Load_ (1:T+(hrs-H));

ARIMA_Close1 = arima(hrs,degree,hrs);
rng(1); % For reproducibility
opt = forecastOptions('InitialCOndition','z');
train=past_data;

forecasted=[];
forecasted_daily_matrix_PV=zeros(H,floor((All-T)/hrs));
real_daily_matrix_PV=zeros(H,floor((All-T)/hrs));
[ARIMA_Close1,~,Loglikehood] = estimate(ARIMA_Close1,train);
for i=1:(All-T)/hrs

Forecast = forecast(ARIMA_Close1,H,'Y0',train);

% Cleaning the Forecast
yf=Forecast;
yf(yf<0)=0;

% Storing
forecasted=[forecasted,(train(end-(hrs-H)+1:end,1))',yf'];
forecasted_daily_matrix_PV(:,i)=yf;
real=Load_(T+(hrs-H)+1+hrs*(i-1):T+hrs*i);
real_daily_matrix_PV(:,i)=real;


if i<(All-T)/hrs
train= Load_ (1:T+(hrs-H)+hrs*i);
end

end


yy=Load_(T+1:All);
yy=yy';


end
