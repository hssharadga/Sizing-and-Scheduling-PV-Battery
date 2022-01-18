Load_=PV__';

hrs=13; % Fixed. The forecasting horizon is between 6 am and 6 pm

All=length(Load_);
T=floor (0.7*All);
delta_T=rem(T,hrs);
T=T-delta_T;

%% degree of ARIMA
degree=2;

if H==8||H==3 % For the stability issue
degree=1;
end

if H==9
degree=3;
end

%%
past_data=Load_ (1:T+(hrs-H));

ARIMA_Close1 = arima(hrs,degree,hrs);

rng(1); % For reproducibility

opt = forecastOptions('InitialCOndition','z');

train=past_data;
forecasted=[];
[ARIMA_Close1,~,Loglikehood] = estimate(ARIMA_Close1,train);
for i=1:(All-T)/hrs

Forecast = forecast(ARIMA_Close1,H,'Y0',train);

yf=Forecast;
yf(yf<0)=0;

forecasted=[forecasted,(train(end-(hrs-H)+1:end,1))',yf'];

if i<(All-T)/hrs
train= Load_ (1:T+(hrs-H)+hrs*i); 
end

end

%%
yy=Load_(T+1:All);
yy=yy';

Targets=yy;
Outputs=forecasted;
    Errors = Targets - Outputs;
    MSE = mean(Errors.^2);
    RMSE = sqrt(MSE);
    ErrorMean = mean(Errors);
    ErrorStd = std(Errors);
    
    subplot(2,2,[1 2]);
    plot(Targets);
    hold on;
    plot(Outputs)
    legend('Observed','Forecasted');
    ylabel('PV [W]');
    xlabel('Time [hr]')
    grid on;
    title('Test Data, 1 step ahead');
    
    subplot(2,2,3);
    plot(Errors);
    title([' RMSE = ' num2str(RMSE)]);
    ylabel('Errors');
    grid on;
    
    subplot(2,2,4);
    histfit(Errors, 50);
    title(['Error Mean = ' num2str(ErrorMean) ', Error StD = ' num2str(ErrorStd)]);

if ~isempty(which('plotregression'))
    figure;
    plotregression(Targets, Outputs, 'TestData');
end