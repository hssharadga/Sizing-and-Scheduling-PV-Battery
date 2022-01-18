
Load_=Load__';

hrs=15; % Fixed. The forecasting horizon is between 4 am and 6 pm
All=length(Load_);
T=floor (0.7*All);
T=180*hrs;
delta_T=rem(T,hrs);
T=T-delta_T;

past_data=Load_ (1:T+(hrs-H));
ARIMA_Close1 = arima(15,2,15);

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
    figure
    subplot(2,2,[1 2]);
    plot(Targets/1000);
    hold on;
    plot(Outputs/1000)
    legend('Observed','Forecasted');
    ylabel('Load (kW)');
    xlabel('[hr]')
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