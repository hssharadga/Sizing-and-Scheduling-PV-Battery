
%% Load Data

global Load;

i=1;
if i==1
Full=csvread('isd1.csv');% school
Full=Full(329088:329088+96*365-1);% Load profile for one year, starts on January 1, 2010 at 12:00 AM (00:00 in 24 hr style)

elseif i==2 
Full=csvread('theater11.csv');
Full=Full(502848:502848+96*365-1);% Theater

elseif i==3
Full=csvread('church12.csv');
Full=Full(434112:434112+96*365-1); % Church

elseif i==4
Full=csvread('hotel.csv');
Full=Full(500544:500544+96*365-1); % Hotel

end

%% Processing the data


if J==1
Load_=Full(1:360*24*4);% The data is recorded every 15 minutes, thus 4*24 points for one day and 360 is assmed to be the 12 months  (We know that 12 months is 365 days)
else
Load_=Full(96*3+1:96*4);% One day simulation
end



Load_=Load_*1000;% Convert from kW to W

% Convert the 15-minute to hourly
Load_ = reshape(Load_,4,[]);
Load=mean(Load_);




