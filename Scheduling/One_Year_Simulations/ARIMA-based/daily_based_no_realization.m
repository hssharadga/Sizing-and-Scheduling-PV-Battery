
%% Cleaning: remove the day of low load to enhance the prediction results
clearnce=[];
for i=1:258                                                % Number of days after removing the weekends is 258
    if max(work_day_Train_(15*(i-1)+1:15*i))/1000<200      % 15 is the horizon
        r=(15*(i-1)+1:15*i);
        clearnce=[clearnce,r];
    end
end
%%
work_day_Train_cleaned=work_day_Train_;
work_day_Train_cleaned(clearnce)=[];

train1=work_day_Train_cleaned';
train11=train1;
forecasted1=[];

%% ARIMA Training: Load
ARIMA_Close1 = arima(15,1,15);
rng(1); % For reproducibility
opt = forecastOptions('InitialCOndition','z');
[ARIMA_Close1,~,Loglikehood] = estimate(ARIMA_Close1,train1);

%%
train2=PV__';
forecasted2=[];
train22=train2;

%% ARIMA Training: PV
ARIMA_Close2 = arima(13,1,13);
rng(1); % For reproducibility
opt = forecastOptions('InitialCOndition','z');
[ARIMA_Close2,~,Loglikehood] = estimate(ARIMA_Close2,train2);


%% Initialize
day_num=0;
Peak_monthly=zeros(1,12);
day_of_week=0;                            % 7 days in a week, it can not be higher than 7
peak_monthly_all=[];                      % Monthly peak (12 peaks in a year)
peak_all_daily_based_no_realization=[];   % Daily peak (360 peaks in a year)

%% Looping
for i=1:360
    
    day_num=day_num+1
    day_of_week=day_of_week+1;
    
    
    % If weeked no peak shaving
    if day_of_week==6 ||day_of_week==7                % weekend

        if day_of_week==7
            day_of_week=0;
        end
        start=16+1+96*(day_num-1);                    % 4am
        endd=16+60+96*(day_num-1);                    % 6pm
        demand_=Load_Test_15_full(start:endd)/1000;
        PV_Power_=PV_15(start:endd)/1000;

        peak=max(demand_-PV_Power_'*N_PV);                         % no battery discharing in weekends
        peak_all_daily_based_no_realization=[peak_all_daily_based_no_realization,peak];
        train22=[train2;PV__(1:13*day_num)'];                      % Update the train data that will be used to forecast the PV of the next day
                                                                   % The weekends data will not be added to the Load training-data
                                                                 
        continue
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%

   
    %% Forecasting:
    
    % Load Forecasting
    Forecast1 = forecast(ARIMA_Close1,15,'Y0',train11);
    yf1=Forecast1;
    yf1(yf1<0)=0;      % The load is nonegative    
    
    % Updating the load train-data that will be used to forecast the Load of the next day:
    % train11=[train1;work_day_Test_(1:15*day_num)]
    if max(work_day_Test_(15*(day_num-1)+1:15*day_num))/1000>150
        % Add the current day to the training date if the load is not low.
        % The the training date  will be used to predict the coming day
        train11=[train11;work_day_Test_(15*(day_num-1)+1:15*day_num)'];                                                                        
    end
    
    
    % PV Forecasting
    Forecast2 = forecast(ARIMA_Close2,13,'Y0',train22);
    yf2=Forecast2;
    yf2(yf2<0)=0;                        % The PV is nonegative

    
    % updating the PV train-data that will be used to forecast the PV of
    % the next day:
    train22=[train2;PV__(1:13*day_num)'];
    
    
    % Forecasted results
    Load_Profile=yf1/1000;
    PV_Profile=yf2*N_PV/1000;
    if horizon==15
        PV_Profile=[0;0;PV_Profile]; % Load is 15 hrs (4am to 6pm) while the PV is 13 hrs(6am to 6pm)
    end
    if horizon==14
        PV_Profile=[0;PV_Profile];
    end

    
    %% CVX Optimization
    cvx_solver SDPT3;
    E0=Es0;                      % E0 is the energy sotrd in the battery at t=0, in [kwh]
    L = 1*tril(ones(horizon));   % hourly based scheduling

    cvx_begin quiet
    variable u(horizon);
    Es = E0+cb*L*u;              % Es is the energy sotrd in the battery at t, in [kwh]
    demand_=Load_Profile;        % Forecasted
    PV_Power_=PV_Profile;        % Forecasted
    grid=demand_+cb*max(eta*u,u/eta)-PV_Power_;
    minimize sum(max(grid,0))*rate+rate_max.*max((grid));   % max(grid,0): The grid receives the access PV energy for free
    subject to
        0<=Es<=cb;              % Constraints on the battery stored energy
        u>=control_min;         % Constraints on the charging rate  
        u<=control_max;
    cvx_end
    %% Assigning
    u=u;                             % Convert the variable from CVX variable to MATLAB variable

    L = 0.25*tril(ones(4*horizon));  % Here we calcualte the 15-mins peak; 0,25 is 1/4 hr (15-mins)
    xx=repelem(u,4);                 % Convert the hourly-average schedule to 15-mins schedule
    
    % Real profiles
    start=16+1+96*(day_num-1);
    endd=16+60+96*(day_num-1);
    demand_=Load_Test_15_full(start:endd)/1000;         % Real(Actual) profiles
    PV_Power_=PV_15(start:endd)/1000;                   % Real(Actual) profiles


    grid=demand_+cb*max(eta*xx,xx/eta)-N_PV*PV_Power_'; % Real(Actual) grid
    Es = E0+cb*L*xx;                                    % Es is the energy sotrd in the battery at t, in [kwh]
 
    % Store the daily peak for the current day
    peak=max(grid);
    peak_all_daily_based_no_realization=[peak_all_daily_based_no_realization,peak];

end 

%% Saving
csvwrite('C:\Users\hssharadga\Desktop\Spring 2021\One year\Forecast Results\peak_all_daily_based_no_realization.csv',peak_all_daily_based_no_realization)



  