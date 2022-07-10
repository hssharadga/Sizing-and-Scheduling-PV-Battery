
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
train1=Load_Train';
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
peak_monthly_all=[];
Peaks_all=[];          % Daily Peak (360 Peaks in a year)

%% Looping
for i=1:360
    
    Peak=0;
    day_num=day_num+1
    day_of_week=day_of_week+1;
    
    
     % If weekend then no peak shaving   
    if day_of_week==6 ||day_of_week==7 % weekend

        if day_of_week==7
            day_of_week=0;
        end
        peak=0;
        Peaks_all=[Peaks_all,peak];
        train22=[train2;PV_(1:13*day_num)'];               % Update the train data that will be used to forecast the PV of the next day
        continue                                           % The weekends data will not be added to the Load training-data   
    end
   
    
    % Start of each day
    E0=Es0;      % E0 is the energy sotrd in the battery at t=0, in [kwh], The battery will be fully charged at the 4am every day as we charge it at the night
    train111=train11;
    train222=train22;
    u_receding=[];
    
    
    for i=1:15      % Receding scheduling horizon and Receding Forecasting horizon

        Horizon_new=horizon-(i-1);
        

        %% Forecasting

        % A: Load Forecasting& updating the training data
        Forecast1 = forecast(ARIMA_Close1,Horizon_new,'Y0',train111);
        yf1=Forecast1;
        yf1(yf1<0)=0; % The Load is nonegative

        % updating the training data every one hour so we can update the forecasted profiles every one hour 
        reced=(15-Horizon_new);
        train111=[train11;Load_Test_(15*(day_num-1)+1:15*(day_num-1)+1+reced)'];



        % B: PV Forecasting & updating the training data
        if (Horizon_new==15 || Horizon_new==14)             % The horizon of Load and PV are different so we shift the PV
            Forecast2 = forecast(ARIMA_Close2,13,'Y0',train222);
            reced=(0);
        else
             Forecast2 = forecast(ARIMA_Close2,Horizon_new,'Y0',train222);
             reced=(13-Horizon_new);
             train222=[train22;PV_(13*(day_num-1)+1:13*(day_num-1)+1+reced)'];
        end
        yf2=Forecast2;
        yf2(yf2<0)=0;   % The PV is nonegative


        % C: Forecasted results
        Load_Profile=yf1/1000;
        PV_Profile=yf2*N_PV/1000;

        if Horizon_new==15        % The horizon of Load and PV are different so we shift the PV
            PV_Profile=[0;0;PV_Profile];
        end
        if Horizon_new==14
            PV_Profile=[0;PV_Profile];
        end

    %% CVX Optimization
%         cvx_solver SDPT3;

        L = 1*tril(ones(Horizon_new));  % hourly based scheduling

        cvx_begin quiet
        variable u(Horizon_new);
        Es = E0+Cb*L*u;                 % Es is the energy sotrd in the battery at t, in [kwh]
        demand_=Load_Profile;           % forecasted
        PV_Power_=PV_Profile;           % forecasted
        grid=demand_+Cb*max(eta*u,u/eta)-PV_Power_;
        minimize sum(max(grid,0))*0.05+7.*max(max(grid),Peak); % max(grid,0): The grid receives the excess PV energy for free
        subject to
            0<=Es<=Cb;                   % Constraints on the battery stored energy
            u>=control_min;              % Constraints on the charging rate  
            u<=control_max;
        cvx_end

        %% Assigning
        u=u;                          % Convert the variable from CVX variable to MATLAB variable
        u_receding=[u_receding,u(1)]; % Stroring every one hour

        % Updating the battery initial status (E0) for the next step (step = one hour)
        Es = E0+Cb*L*u;
        E0=Es(1);

        % Peak will be updated based on hourly realization
        Real_Load=Load_Test_(15*(day_num-1)+1:15*(day_num))/1000;   % Real value (Test data)
        Real_PV=PV_(13*(day_num-1)+1:13*(day_num))*N_PV/1000;       % (We do not have Test data for PV so we assuem the PV for the coming year will be the same of the previous year)
        if Horizon_new==15
            Real_PV=[0,0,Real_PV];
        elseif Horizon_new==14
            Real_PV=[0,Real_PV];
        end    
        demand__=Real_Load(end-(Horizon_new)+1:end);
        PV_Power__=Real_PV(end-(Horizon_new)+1:end);
        grid_real=demand__+Cb*max(eta*u',u'/eta)-PV_Power__';
        Peak=max(Peak,max(grid_real(1)));                           % Peak Target has been recorded so far

    end
 
    % End of the day: Update the train-data 
    % updating the Load and PV train-data that will be used to forecast the Load and PV of the next day:
    if max(Load_Test_(15*(day_num-1)+1:15*day_num))/1000>150
        train11=[train11;Load_Test_(15*(day_num-1)+1:15*day_num)'];
    end
    train22=[train22;PV_(13*(day_num-1)+1:13*day_num)'];

    %% Peak 15-mins over the day
    u_=repelem(u_receding,4);
    start=16+1+96*(day_num-1);   % 4 A.M
    endd=16+60+96*(day_num-1);   % 6 P.M
    PV_Power_15=PV_15(start:endd)/1000;
    demand_15=Load_Test_15_full(start:endd)/1000;
    demand__=demand_15;
    PV_Power__=PV_Power_15;
    grid_real=demand__+Cb*max(eta*u_',u_'/eta)-N_PV*PV_Power__';
    Peak=max(grid_real);

    % Recording 
    Peaks_all=[Peaks_all,Peak];

end 
    
% %% Saving
Peaks_all
% csvwrite('C:\Users\hssharadga\Desktop\Spring 2021\One year\Forecast Results\Peaks_all3.csv',Peaks_all)


  
