
%% Convert the 258 days to 51 full weeks
train1=Load_Train_(1:end-3*15)'; % 51 weeks of 255 days.  It was 258 days
train11=train1;
train2=PV__(1:end-3*13)';
train22=train2;


%% Storing  the days of the same name in one group

train11=reshape( train11,[], 255 );
train22=reshape( train22,[], 255 );

% Load
day=train11(:,1:5:255)/1000;
day2=train11(:,2:5:255)/1000;
day3=train11(:,3:5:255)/1000;
day4=train11(:,4:5:255)/1000;
day5=train11(:,5:5:255)/1000;
Load_Profile=cell(1,5);
Load_Profile{1,1}=day;
Load_Profile{1,2}=day2;
Load_Profile{1,3}=day3;
Load_Profile{1,4}=day4;
Load_Profile{1,5}=day5;


% PV
day=train22(:,1:5:255)/1000*N_PV;
day2=train22(:,2:5:255)/1000*N_PV;
day3=train22(:,3:5:255)/1000*N_PV;
day4=train22(:,4:5:255)/1000*N_PV;
day5=train22(:,5:5:255)/1000*N_PV;
PV_Profile=cell(1,5);
PV_Profile{1,1}=day;
PV_Profile{1,2}=day2;
PV_Profile{1,3}=day3;
PV_Profile{1,4}=day4;
PV_Profile{1,5}=day5;

%% intilize
day_num=0;
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
        peak=0;
        Peaks_all=[Peaks_all,peak];

        continue
    end
    

    %% Calling
    Load_Profile_=Load_Profile{1,day_of_week};
    PV_Profile_=PV_Profile{1,day_of_week};
    
    if horizon==15       % The horizon of Load and PV are different so we shift the PV
        PV_Profile_=[zeros(2,51);PV_Profile_];
    end
    if horizon==14
        PV_Profile_=[zeros(1,51);PV_Profile_];
    end
    
    

%% CVX Optimization: Find the common optimal battery schedule over the days of the same name

% cvx_solver SDPT3;
E0=Es0;
L = 1*tril(ones(horizon));

cvx_begin quiet
variable x(horizon,1);
Es = E0+Cb*L*x;
demand_=Load_Profile_;
PV_Power_=PV_Profile_;
grid=demand_+repelem(Cb*max(eta*x,x/eta),1,51)-PV_Power_;  % 51 is 51 weeks. We have 51 Mondays, 51 Tuesdays, ...
minimize sum(sum(max(grid,0))*0.05)+sum(7.*max((grid)));

subject to
0<=Es<=Cb;
 x>=control_min;
 x<=control_max;
cvx_end
 
%% Assigning
 x=x; % Convert the variable from CVX variable to MATLAB variable
%% 
L = 0.25*tril(ones(4*horizon));
xx=repelem(x,4);

% Real profiles (Load and PV)
start=16+1+96*(day_num-1);
endd=16+60+96*(day_num-1);
demand_=Load_Test_15_full(start:endd)/1000;
PV_Power_=PV_15(start:endd)/1000;


grid=demand_+Cb*max(eta*xx,xx/eta)-N_PV*PV_Power_';% real grid
Es = E0+Cb*L*xx;

% Record the daily peak
peak=max(grid);
Peaks_all=[Peaks_all,peak];
 

end 

%%
% csvwrite('C:\Users\hssharadga\Desktop\Spring 2021\One year\Forecast Results\peak_all_daily_based__common_day_of_week.csv',Peaks_all)



  