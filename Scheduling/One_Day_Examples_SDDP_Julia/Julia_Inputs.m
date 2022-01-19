% Preparing the data for Julia

global per_Load
global per_PV     

%% The scenarios
 csvwrite('per_Load.csv',per_Load)
 csvwrite('per_PV.csv',per_PV)
 
%% 1) Taking the transpose so we can store them as csv

forecasted_Load_daily_matrix_new=cell(1,15);
forecasted_PV_daily_matrix_new=cell(1,15);
real_daily_matrix_Load_new=cell(1,15);
real_daily_matrix_PV_new=cell(1,15);
for i=1:15
    
 row_col=forecasted_Load_daily_matrix_{i}';
 forecasted_Load_daily_matrix_new{1,i}=row_col;
 
 row_col=real_daily_matrix_Load_{i}';
 real_daily_matrix_Load_new{1,i}=row_col;
 
end

for i=1:13
 
 row_col=forecasted_PV_daily_matrix_{i}';
 forecasted_PV_daily_matrix_new{1,i}=row_col;
 
 row_col_=real_daily_matrix_PV_{i}';
 real_daily_matrix_PV_new{1,i}=row_col_;
 
end
%% 2) Correction for PV (the difference in the forecasting horizon)

per_corr=zeros(108,1);% The first correction
forecasted_PV_daily_matrix_new{1,hrs+1}=[per_corr,row_col];
real_daily_matrix_PV_new{1,hrs+1}=[per_corr,row_col_];

per_corr=zeros(108,2);% The second correction
forecasted_PV_daily_matrix_new{1,hrs+2}=[per_corr,row_col];
real_daily_matrix_PV_new{1,hrs+2}=[per_corr,row_col_];

%% 3)

csvwrite('forecasted_Load_daily_matrix_new.csv',forecasted_Load_daily_matrix_new)
csvwrite('forecasted_PV_daily_matrix_new.csv',forecasted_PV_daily_matrix_new)

csvwrite('real_daily_matrix_Load_new.csv',real_daily_matrix_Load_new)
csvwrite('real_daily_matrix_PV_new.csv',real_daily_matrix_PV_new)

%%

csvwrite('PV_15.csv',PV_15')     % 15-mins PV Profile
csvwrite('Load_15.csv',Load_15)  % 15-mins Load




