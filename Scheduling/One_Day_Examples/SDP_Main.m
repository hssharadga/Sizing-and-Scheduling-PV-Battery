%% Estimating the future cost (V)
tic
global control_max % maximum u charging rate
global control_min % minimum u charging rate
global horizon
global t0
global bT
global T
global controls
global Es_states
global peak_states
global N_PV
global res1
global res2
%% A: The states
Es_states=linspace(0,100,101);    % 101 different states for Es (energy stored in battery)
peak_states=linspace(0,100,101);  % 101 different states for the Peak

%% B: State discretization (Stochastic Dynamic Programming)

res1=10;    % The energy stored in the battery (step size)   10 kWh
res2=10;    % The peak value (step size)                     10 kW

% Based on A and B:energy stored in the battery  (Es) is between 0 and 1000 [kWh]

%% Time and controls
t0=1;
horizon=15;
T=t0:(horizon);
bT=t0:(horizon);
controls=linspace(control_min,control_max,100); 

%%  Lengths
global Length_Es_states
global Length_peak_states
global Length_controls
[~,Length_Es_states]=size(Es_states);
[~,Length_peak_states]=size(peak_states);
[~,Length_controls]=size(controls);

%% The future cost (V)
global V
[V] = SDP(Load_Forecast'/1000, N_PV*PV_Forecast'/1000);% input in [kW]

total_time=toc


