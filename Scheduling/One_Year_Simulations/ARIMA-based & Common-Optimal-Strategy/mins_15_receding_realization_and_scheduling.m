%% Cleaning: remove the days of low load to enhance the prediction results
clearnce=[];
for i=1:258
    if max(Load_Train_(15*(i-1)+1:15*i))/1000<200
        r=(15*(i-1)+1:15*i);
        clearnce=[clearnce,r];
    end
end
Load_Train=Load_Train_;
Load_Train(clearnce)=[];

%% Assign: Load data
train1=Load_Train_';
train11=train1;

%% ARIMA Training: Load
ARIMA_Close1 = arima(15,1,15);
rng(1); % For reproducibility
opt = forecastOptions('InitialCOndition','z');
[ARIMA_Close1,~,Loglikehood] = estimate(ARIMA_Close1,train1);

%% Assign: PV data
train2=PV_';
train22=train2;

%% ARIMA Training: PV
ARIMA_Close2 = arima(13,1,13);
rng(1); % For reproducibility
opt = forecastOptions('InitialCOndition','z');
[ARIMA_Close2,~,Loglikehood] = estimate(ARIMA_Close2,train2);


%% Initialize
day_num=0;
Peak_monthly=zeros(1,12);
day_of_week=0;

Peaks_all=[];

horizon=15;
%% Looping
for i=1:360
    Peak=0;
    day_num=day_num+1
    start=16+1+96*(day_num-1);% 4 A.M
    endd=16+60+96*(day_num-1);% 6 P.M
    PV_Power_15=PV_15(start:endd)/1000;
    demand_15=Load_Test_15_full(start:endd)/1000;
    day_of_week=day_of_week+1;
    
    % If weekend then no peak shaving   
    if day_of_week==6 ||day_of_week==7% weekend

        if day_of_week==7
            day_of_week=0;
        end
        peak=0;
        Peaks_all=[Peaks_all,peak];
        train22=[train2;PV_(1:13*day_num)'];      % Update the train data that will be used to forecast the PV of the next day
        continue                                   % The weekends data will not be added to the Load training-data  
    end
   
    % Every day
    E0=Es0; % E0 is the energy sotrd in the battery at t=0 in [kwh]. The battery will be fully charged at the 4am every day as we charge it at the night
    train111=train11;
    train222=train22;
    x_receding=[];
    
 for i=1:15                     % Receding Forecasting horizon (The forecasted values are updated every one hour)
    Horizon_new=horizon-(i-1);
    
    %% Forecasting
    
    % A: Load Forecasting& updating the training data
   
    Forecast1 = forecast(ARIMA_Close1,Horizon_new,'Y0',train111);
    yf1=Forecast1;
    yf1(yf1<0)=0; % The load is nonegative  
    % updating the training data every one hour so we can update the forecasted profiles every one hour 
    reced=(15-Horizon_new);
    train111=[train11;Load_Test_(15*(day_num-1)+1:15*(day_num-1)+1+reced)'];

    
    % B: PV Forecasting & updating the training data
    if (Horizon_new==15 || Horizon_new==14)           % The horizon of Load and PV are different so we shift the PV
        Forecast2 = forecast(ARIMA_Close2,13,'Y0',train222);
        reced=(0);
    else
         Forecast2 = forecast(ARIMA_Close2,Horizon_new,'Y0',train222);
         reced=(13-Horizon_new);
         train222=[train22;PV_(13*(day_num-1)+1:13*(day_num-1)+1+reced)'];% update
    end
    
    yf2=Forecast2;
    yf2(yf2<0)=0;   % The PV is nonegative

    
    % C: Forecasted results
    Load_Profile=yf1/1000;
    PV_Profile=yf2*N_PV/1000;
    
    if Horizon_new==15                 % Load is 15 hrs (4am to 6pm) while the PV is 13 hrs(6am to 6pm)
        PV_Profile=[0;0;PV_Profile]; 
    end
    if Horizon_new==14
        PV_Profile=[0;PV_Profile];
    end

%% CVX Optimization,  15-mins based and receding scheduling 
PV_Profile=repelem(PV_Profile,4);
Load_Profile=repelem(Load_Profile,4);
if Horizon_new==1
    Load_Profile=Load_Profile';
    PV_Profile=PV_Profile';
end
    
for iji=1:4

Horizon__=Horizon_new*4-iji+1;

L = 0.25*tril(ones(Horizon_new*4-iji+1)); % 0.25 becuase it is 15-mins
demand_=Load_Profile(iji:end);            % forecasted
PV_Power_=PV_Profile(iji:end);            % forecasted

cvx_begin quiet
variable x(Horizon__);

grid=demand_+Cb*max(eta*x,x/eta)-PV_Power_;
Es = E0+Cb*L*x;

minimize (sum(max(grid,0)).*0.05+7.*(max(max(grid),Peak)))

subject to
    0<=Es<=Cb;
    x>=control_min;
x<=control_max;
cvx_end

%% Assigning
x_=x; % Convert the variable from CVX variable to MATLAB variable
x_receding=[x_receding,x_(1)];


% Updating the battery initial status (E0) for the next step (step = 15 mins)
Es = E0+Cb*L*x_;
E0=Es(1);


% Peak will be updated based on 15-mins realization
demand__=demand_15(end-(Horizon_new*4-iji+1)+1:end);
PV_Power__=PV_Power_15(end-(Horizon_new*4-iji+1)+1:end);
grid_real=demand__+Cb*max(eta*x_,x_/eta)-N_PV*PV_Power__';
Peak=max(grid_real(1),Peak);          % Peak Target has been recorded so far
end

 end
 
% End of the day: Update the train-data 
% updating the Load and PV train-data that will be used to forecast the Load and PV of the next day:
if max(Load_Test_(15*(day_num-1)+1:15*day_num))/1000>150
    train11=[train11;Load_Test_(15*(day_num-1)+1:15*day_num)'];% update
end
train22=[train22;PV_(13*(day_num-1)+1:13*day_num)'];% update

%% Peak 15-mins over the day

demand__=demand_15;
PV_Power__=PV_Power_15;
 
grid_real=demand__+Cb*max(eta*x_receding',x_receding'/eta)-N_PV*PV_Power__';
Peak=max(grid_real);

% Recording 
Peaks_all=[Peaks_all,Peak]; 
end 
    
% %% Saving
% csvwrite('C:\Users\hssharadga\Desktop\Spring 2021\One year\Forecast Results\Peaks_all4.csv',Peaks_all)






  