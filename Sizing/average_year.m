% Constant
N_PV=500;
cb=450;
Es0=cb;
control_min=-1;
control_max=0.4;
eta=0.92;

num_day_lag=218;% fixed

%% Training 
%Load
% ARIMA_Close1 = arima(15,1,15);
% rng(1); % For reproducibility
% opt = forecastOptions('InitialCOndition','z');

clearnce=[];
%% cleaning
for i=1:258
    if max(work_day_Train_(15*(i-1)+1:15*i))/1000<200
        r=(15*(i-1)+1:15*i);
        clearnce=[clearnce,r];
    end
end
%%
work_day_Train_cleaned=work_day_Train_;
work_day_Train_cleaned(clearnce)=[];
train1=work_day_Train_cleaned';
train11=train1;
% forecasted1=[];
% [ARIMA_Close1,~,Loglikehood] = estimate(ARIMA_Close1,train1);

% PV
% ARIMA_Close2 = arima(13,1,13);
% rng(1); % For reproducibility
% opt = forecastOptions('InitialCOndition','z');

train2=PV__';
% forecasted2=[];
% [ARIMA_Close2,~,Loglikehood] = estimate(ARIMA_Close2,train2);
train22=train2;
%% intilize
day_num=0;
Peak_monthly=zeros(1,12);
Cost_mointhly=zeros(1,12);
day_of_week=0;
Total_consumption=0;
peak_monthly_all=[];
peak_all_daily_based_average_year=[];

horizon=15;
%%
for i=1:360
    
    day_num=day_num+1
    day_of_week=day_of_week+1;
    if day_of_week==6 ||day_of_week==7% weekend
%         Grid= Load-PV*N_PV
%         Total_consumption=sum (Grid)*0.05% units?
        if day_of_week==7
            day_of_week=0;
        end
        peak=0
        peak_all_daily_based_average_year=[peak_all_daily_based_average_year,peak];
        train22=[train2;PV__(1:13*day_num)'];

        continue
    end
    
 
    
    %% Forecasting
    %Load Forecasting
%     Forecast1 = forecast(ARIMA_Close1,15,'Y0',train11);
%     yf1=Forecast1;
%     yf1(yf1<0)=0;
%     forecasted1=[forecasted1,yf1'];
    
    % updating the train data
%     train11=[train1;work_day_Test_(1:15*day_num)]

    % PV Forecasting
%     Forecast2 = forecast(ARIMA_Close2,13,'Y0',train22);
%     yf2=Forecast2;
%     yf2(yf2<0)=0;  
%     forecasted2=[forecasted2,yf1'];
    
    % updating the train data
%     train22=[train2;PV__(1:13*day_num)']
%     train22=[train22;PV__(13*(day_num-1)+1:13*day_num)'];

    
    Load_Profile=train1/1000;
    corrected_number_of_day_in_year=length(train1)/15;
    Load_Profile=reshape( Load_Profile,[], corrected_number_of_day_in_year );
    
%     if num_day_lag>1
        Load_Profile=mean(Load_Profile');
%     else
%         
%         Load_Profile=Load_Profile';
%     end

    PV_Profile1=train2/1000;
    PV_Profile=reshape( PV_Profile1,[], 360 )/1000*N_PV;
    
%     if num_day_lag>1
        PV_Profile=mean(PV_Profile');
%     else
%         PV_Profile=PV_Profile';
%     end
    
    
    if horizon==15
        PV_Profile=[0;0;PV_Profile'];
    end
    if horizon==14
        PV_Profile=[0;PV_Profile'];
    end
    
    
    if max(work_day_Test_(15*(day_num-1)+1:15*day_num))/1000>150
        train11=[train11;work_day_Test_(15*(day_num-1)+1:15*day_num)'];
    end
        train22=[train2;PV__(1:13*day_num)'];
    %% Test the forecasting
%     plot(Load_profile,'--')
%     Real_Load=work_day_Test_(15*day_num+1:15*(day_num+1))/1000
%     hold on
%     plot(Real_Load,'-')
%     plot(PV_Profile,'--')
%     Real_PV=PV__(13*day_num+1:13*(day_num+1))*N_PV/1000
%     plot(Real_PV,'-')
    
%% CVX
cvx_solver SDPT3;
E0=Es0;
L = 1*tril(ones(horizon));

cvx_begin quiet
variable x(horizon);
Es = E0+cb*L*x;
demand_=Load_Profile;% forecasted
PV_Power_=PV_Profile;% forecasted

grid=demand_'+cb*max(eta*x,x/eta)-PV_Power_;
minimize sum(max(grid,0))*0.05+7.*max((grid));
% minimize sum(max(grid,0))*0.05+7.*max((grid))+(cb-Es(end))/(eta)*0.045;

subject to
0<=Es<=cb;
 x>=control_min;
 x<=control_max;
cvx_end
 
 %%
 x=x;
 
L = 0.25*tril(ones(4*horizon));
xx=repelem(x,4);
% real profiles
start=16+1+96*(day_num-1);
endd=16+60+96*(day_num-1);
demand_=Load_Test_15_full(start:endd)/1000;
PV_Power_=PV_15(start:endd)/1000;


 grid=demand_+cb*max(eta*xx,xx/eta)-N_PV*PV_Power_';% real grid
 Es = E0+cb*L*xx;
 
 % Update the daily peak
 peak=max(grid);
 peak_all_daily_based_average_year=[peak_all_daily_based_average_year,peak];
 
 
% Test the profiles
% figure
% yyaxis left
% Load=repelem(Load_Profile,4);
% plot(Load,'k--')
% hold on
% plot(demand_,'k-')
% plot(grid,'g-')
% yyaxis right
% plot(Es,'r-')
% e=1

end 

%%
csvwrite('C:\Users\hssharadga\Desktop\Spring 2021\One year\Forecast Results\peak_all_daily_based__average_year.csv',peak_all_daily_based_average_year)

%%
% ju=1
% if ju==1
%     directory=['C:\Users\hssharadga\Desktop\Spring 2021\One year\Forecast Results\peak_all_daily_based_no_realization',num2str(ju),'.csv']
% csvwrite(directory,peak_all_daily_based_no_realization)
% end

  
