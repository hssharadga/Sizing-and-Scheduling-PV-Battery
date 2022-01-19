%% Day_number_correction


% To find the PV day number

% To calcuate the day number in the year out of 360
if mod(day_number,5)~=0
    day_=(floor(day_number/5))*7+mod(day_number,5)+255;
else
    day_=(floor(day_number/5))*7+-2+255;
end  
% To find the PV day number out of 108      108 days for test and 252 for training
PV_day_number=day_-252;

%% load and PV profiles

% Forecasted Profiles
PV_Forecast0=forecasted_PV_daily_matrix_{horizon-2};
PV_Forecast1=PV_Forecast0(:,PV_day_number);
PV_Forecast=[0;0;PV_Forecast1];% Correction: Load horizon is 15 hrs while the PV horizon  is 13 hrs (see Loading_and_Cleaning script)


Load_Forecast0=forecasted_Load_daily_matrix_{horizon};
Load_Forecast=Load_Forecast0(:,day_number);

%  Real Profiles
global PV_real_given_day_
PV_real_=real_daily_matrix_PV_{horizon-2};
PV_real_given_day_0=PV_real_(:,PV_day_number);
PV_real_given_day_=[0;0;PV_real_given_day_0];

global Load_real_given_day_
Load_real_=real_daily_matrix_Load_{horizon};
Load_real_given_day_=Load_real_(:,day_number);

