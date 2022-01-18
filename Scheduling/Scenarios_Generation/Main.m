% Main

Loading_and_Cleaning % Load the data and preparing it for training (forecasting)

H=15; % See comments below:
% It should NOT be higher than 15 for the load and 13 for the PV
% H is the new horizon of forecasting. For example the the forecasting horizon for
% the Load is 15 hours (4 am to 6 pm) but the  forecasting horizon is
% receding, i.e, start with 15 and then decrases to 14 then 13 .... then 1

step=4; % The time-step number in the forecasting horizon. It should be less or equla H

%1
Load_Forecasting_Scenarios % Load: Electrical Load
%2
% PV_Forecasting_Scenarios

Scenarios