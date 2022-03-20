clc
clear all

global rate_max
global rate
global eta
global count; % Number of objective-function calculations

rate_max=7; %[$/kW]
rate=0.05; % [$/kWh]
eta=0.92; % Charging/Discharging Efficiency
count=0;
%% Loading and one-time calculations
Load_Data_Processing; % Load is the the electrical load
Solar_PV_calculations;
%%

tic;

Ib=[1,1];% The lower boundes
Ub=[4000,2000];% The upper bounds

% cvx_solver MOSEK; % Commercial Solver but free for students, this solver found to be significantly better for the current problem

%% Firsit option: Surrogate Optimization
opts = optimoptions('surrogateopt','MaxFunctionEvaluations',35);
intcon=[1,2];% Integer constraint for the first and second variables
[sol,fval,eflag,outpt] = surrogateopt(@Obj,Ib,Ub,intcon,opts)

%% Second option: Fmincon
% max_evaluation=30
% Aeq=[];
% beq =[];
% po=[2000,200]
% A=[];
% b=[];
% nlcon=[];
% options = optimoptions('fmincon','Display','iter','Algorithm','sqp','MaxFunctionEvaluations',max_evaluation);
% p = fmincon(@obj,po,A,b,Aeq,beq,Ib,Ub,nlcon,options) %,options);

%% Third  option: Genetic Algorithm, This one is not efficent for this probelm
% N=length(Ib)
% options = optimoptions(@ga,'MaxStallGenerations',10,'MaxGenerations',200);
% [p,val] = ga(@obj,N,A,b,Aeq,beq,Ib,Ub,nlcon,[1,2],options); %,options);

%% Optimal Sizes and Time Display
time=toc;
disp ('time in mins = ')
disp(time/60)
disp(['Solution NPV/Cb ', num2str(sol)])


