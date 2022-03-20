
num_day_lag=7;% the size of the sliding window


%% cleaning
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

%% Assign: PV data
train2=PV_';
train22=train2;

%% Initialize
day_num=0;
% Peak_monthly=zeros(1,12);
day_of_week=0;
Peaks_all=[];
horizon=15;

%% Looping
for i=1:360
    
    day_num=day_num+1
    day_of_week=day_of_week+1;
    
    % If weekend then no peak shaving   
    if day_of_week==6 ||day_of_week==7% weekend

        if day_of_week==7
            day_of_week=0;
        end
        peak=max(demand_-PV_Power_'*N_PV);% no battery discharing in weekends
        Peaks_all=[Peaks_all,peak];
        train22=[train2;PV_(1:13*day_num)']; % Update the train data that will be used to forecast the PV of the next day
                                              % The weekends data will not be added to the Load training-data 
        continue
    end
    
 
    
    %% Storing  the histroical data in the sliding window as group
    
    Load_Profile=train11(end-15*num_day_lag+1:end)/1000;
    Load_Profile=reshape( Load_Profile,[], num_day_lag );
    Load_Profile=Load_Profile';

    
    PV_Profile1=train22(end-13*num_day_lag+1:end)/1000*N_PV;
    PV_Profile=reshape( PV_Profile1,[], num_day_lag );
    PV_Profile=PV_Profile';

    
    if horizon==15            % The horizon of Load and PV are different so we shift the PV
        PV_Profile=[zeros(2,num_day_lag);PV_Profile'];
    end
    if horizon==14
        PV_Profile=[zeros(1,num_day_lag);PV_Profile'];
    end
    
    
    % Updaing the histroical data:
    
    % A: Load
    if max(Load_Test_(15*(day_num-1)+1:15*day_num))/1000>150 % Cleaning: remove the days of low load to enhance the prediction results
        train11=[train11;Load_Test_(15*(day_num-1)+1:15*day_num)'];
    end
    % B: PV
    train22=[train2;PV_(1:13*day_num)'];
        
        
    
%% CVX Optimization: Find the common optimal battery schedule over the sliding window
% cvx_solver SDPT3;
E0=Es0; % E0 is the energy sotrd in the battery at t=0 in [kwh]. The battery will be fully charged at the 4am every day as we charge it at the night
L = 1*tril(ones(horizon));

cvx_begin quiet
variable x(horizon,1);
Es = E0+Cb*L*x;
demand_=Load_Profile;    % Group of days, the sliding window
PV_Power_=PV_Profile;    % Group
grid=demand_'+repelem(Cb*max(eta*x,x/eta),1,num_day_lag)-PV_Power_;
minimize sum(sum(max(grid,0))*0.05)+sum(7.*max((grid)));
subject to
0<=Es<=Cb;
x>=control_min;
x<=control_max;
cvx_end
 
%% Assigning
 x=x; % Convert the variable from CVX variable to MATLAB variable

%% Peak 15-mins over the day

L = 0.25*tril(ones(4*horizon));
xx=repelem(x,4);

% Real profiles (Load and PV)
start=16+1+96*(day_num-1);
endd=16+60+96*(day_num-1);
demand_=Load_Test_15_full(start:endd)/1000;
PV_Power_=PV_15(start:endd)/1000;


grid=demand_+Cb*max(eta*xx,xx/eta)-N_PV*PV_Power_';  % real grid
Es = E0+Cb*L*xx;

% Record the daily peak
peak=max(grid);
Peaks_all=[Peaks_all,peak];
 
end 

% %% Saving
% csvwrite('C:\Users\hssharadga\Desktop\Spring 2021\One year\Forecast Results\peak_all_daily_based_common.csv',Peaks_all)


  