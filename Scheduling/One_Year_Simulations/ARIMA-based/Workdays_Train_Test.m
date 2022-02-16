%% Cleaning the data

global work_day_Train_cleaned
global work_day_Test_

work_day_Train=Load_Train;  % hourly profile
work_day_Test=Load_Test;    % hourly profile
PV_=PV_hourly;


work_day_Train_15=Load_Train_15_full;
work_day_Test_15=Load_Test_15_full;



%remove the weekend
r_=[];
r2_=[];
for i=1:51                        % The number of weeks in a year is 51
r=(24*7*i-24*2)+1:24*7*i;
r_=[r_,r];

% 15_mins based
r2=(96*7*i-96*2)+1:96*7*i;
r2_=[r2_,r2];
end
work_day_Train(r_)=[];
work_day_Train_15(r2_)=[];

week_day_PV_=PV_;
week_day_PV_(r_)=[];

week_day_PV_15=PV_15;
week_day_PV_15(r2_)=[];

% work_day_Test(r_)=[];% do not remove the weekend form the test
% PV_(r_)=[];


% remove the night values for PV and the load
g_=[];

start=4; % A.M
end_= 6; % P.M

for i=1:258; %the number of day without the weekend
g1=(24*i-23):24*i-(24-start);
g2=(24*i-(12-end_-2)):24*i;
g=[g1,g2];
g_=[g_,g]; 
% gg1=(24*i-23):24*i-18;% 7 a.m
% gg2=(24*i-4):24*i;% 7 P.M

% gg=[gg1,gg2];
% gg_=[gg_,gg];


 
end
work_day_Train_=work_day_Train;
work_day_Train_(g_)=[]; %no weekend no nigth   the load betwwn 5 am and 7 p.m



work_day_Train_15_=[];
week_day_PV_15_=[];
week_day_PV_15=week_day_PV_15';
for i=1:258
        
    
    start=16+1+96*(i-1);                           % 4 A.M
    endd=16+60+96*(i-1);                           % 6 P.M
    %PV_Power_15=PV_15(start:endd)/1000;
    demand_15=work_day_Train_15(start:endd);
    work_day_Train_15_=[work_day_Train_15_;demand_15];
    
    start=16+1+96*(i-1);% 4 A.M
    endd=16+60+96*(i-1);% 6 P.M
    %PV_Power_15=PV_15(start:endd)/1000;
    demand_15=week_day_PV_15(start:endd);
    week_day_PV_15_=[week_day_PV_15_;demand_15]; 

end



work_day_Test_15_=[];
for i=1:360
        
    
    start=16+1+96*(i-1);% 4 A.M
    endd=16+60+96*(i-1);% 6 P.M
    %PV_Power_15=PV_15(start:endd)/1000;
    demand_15=work_day_Test_15(start:endd);
    work_day_Test_15_=[work_day_Test_15_;demand_15];
    
%     start=16+1+96*(i-1);% 4 A.M
%     endd=16+60+96*(i-1);% 6 P.M
%     %PV_Power_15=PV_15(start:endd)/1000;
%     demand_15=week_day_PV_15(start:endd);
%     week_day_PV_15_=[week_day_PV_15_;demand_15]; 

end




g_=[];

start=4; % A.M
end_= 6; % P.M
for i=1:360; %
g1=(24*i-23):24*i-(24-start);
g2=(24*i-(12-end_-2)):24*i;

% gg1=(24*i-23):24*i-18;% 7 a.m
% 
% gg2=(24*i-4):24*i;% 7 P.M
g=[g1,g2];
g_=[g_,g]; 
% gg=[gg1,gg2];
% gg_=[gg_,gg];
end


work_day_Test_=work_day_Test;
work_day_Test_(g_)=[];% remove the night



gg_=[];
start=6; % 7 a.m
end_= 6; % 7 P.M

for i=1:360; %the number of day with the weekend
% g1=(24*i-23):24*i-21;
% g2=(24*i-6):24*i;

gg1=(24*i-23):24*i-(24-start);% 7 a.m

gg2=(24*i-(12-end_-2)):24*i;% 7 P.M
% g=[g1,g2];
% g_=[g_,g]; 
gg=[gg1,gg2];
gg_=[gg_,gg];
end
PV__=PV_;
PV__(gg_)=[];% the power between 6 am and 6 p.m (without ignoring the weekend, thus 360 days (no ignoring the firsit 3 days))



gg_=[];
for i=1:258; %the number of day with the weekend
% g1=(24*i-23):24*i-21;
% g2=(24*i-6):24*i;

gg1=(24*i-23):24*i-(24-start);% 7 a.m

gg2=(24*i-(12-end_-2)):24*i;% 7 P.M
% g=[g1,g2];
% g_=[g_,g]; 
gg=[gg1,gg2];
gg_=[gg_,gg];
end
week_day_PV_(gg_)=[];

%% Cleaning the train data
%% cleaning
clearnce=[];
for i=1:258
    if max(work_day_Train_(15*(i-1)+1:15*i))/1000<200
        r=(15*(i-1)+1:15*i);
        clearnce=[clearnce,r];
    end
end
%
work_day_Train_cleaned=work_day_Train_;
work_day_Train_cleaned(clearnce)=[];
