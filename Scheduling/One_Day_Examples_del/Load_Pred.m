

% Note: for explanation see PV-Pred function


function [yy,forecasted,forecasted_daily_matrix,real_daily_matrix_Load] = Load_Pred(hrs,H)

global Load__
Load_=Load__';

All=length(Load_);

T=floor (0.7*All); % 70 percent for training
T=180*hrs; % 255 days: 180 for training and 75 for testing

delta_T=rem(T,hrs);
T=T-delta_T;

past_data=Load_ (1:T+(hrs-H));

ARIMA_Close1 = arima(hrs,1,hrs);

rng(1);

opt = forecastOptions('InitialCOndition','z');

train=past_data;
forecasted=[];
forecasted_daily_matrix=zeros(H,floor((All-T)/hrs));
real_daily_matrix_Load=zeros(H,floor((All-T)/hrs));
[ARIMA_Close1,~,Loglikehood] = estimate(ARIMA_Close1,train);
for i=1:(All-T)/hrs

Forecast = forecast(ARIMA_Close1,H,'Y0',train);

yf=Forecast;
yf(yf<0)=0;

forecasted=[forecasted,(train(end-(hrs-H)+1:end,1))',yf'];
forecasted_daily_matrix(:,i)=yf;

real=Load_(T+(hrs-H)+1+hrs*(i-1):T+hrs*i);
real_daily_matrix_Load(:,i)=real;

if i<(All-T)/hrs
train= Load_ (1:T+(hrs-H)+hrs*i); 
end

end

yy=Load_(T+1:All);
yy=yy';

end
