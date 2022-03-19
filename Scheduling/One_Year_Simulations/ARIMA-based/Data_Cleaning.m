%% Cleaning the data

Load_Train_=Load_Train;  % Hourly profile
Load_Test_=Load_Test;    % Hourly profile
PV_=PV_hourly;



% Remove the weekends form the Load traning data set
r_=[];
r2_=[];
for i=1:51                        % The number of weeks in a year is 51
r=(24*7*i-24*2)+1:24*7*i;
r_=[r_,r];

% % 15_mins based
% r2=(96*7*i-96*2)+1:96*7*i;
% r2_=[r2_,r2];
end
Load_Train_(r_)=[];
% work_day_Train_15(r2_)=[];




% Remove the night period for the load
g_=[];
start=4;                         % 4 A.M
end_= 6;                         % 6 P.M
for i=1:258;                     % The number of days without the weekend
g1=(24*i-23):24*i-(24-start);
g2=(24*i-(12-end_-2)):24*i;
g=[g1,g2];
g_=[g_,g]; 
end
Load_Train_(g_)=[];              % No weekends and no night period (the load between 4 am and 6 pm)





% Remove the night period for the load
g_=[];
start=4;             % 4 A.M
end_= 6;             % 6 P.M
for i=1:360; 
g1=(24*i-23):24*i-(24-start);
g2=(24*i-(12-end_-2)):24*i;
g=[g1,g2];
g_=[g_,g]; 

end

Load_Test_(g_)=[];                % no night period (the load between 4 am and 6 pm), the weekend will be removed in the looping




% Remove the night period for the PV
gg_=[];
start=6;            % 6 a.m
end_= 6;            % 6 P.M
for i=1:360;
gg1=(24*i-23):24*i-(24-start); % 6 a.m
gg2=(24*i-(12-end_-2)):24*i;   % 6 P.M
gg=[gg1,gg2];
gg_=[gg_,gg];
end
PV_(gg_)=[];                % The power between 6 am and 6 pm (without ignoring the weekends, thus 360 day)




