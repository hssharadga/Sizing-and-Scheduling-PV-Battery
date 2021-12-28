
function LCC = LCC(N_PV,Cb,Q); % Life cycle cost of the system, Cb in kwh
global PV_LCC
global cb_LCC

% general financial data
N=20; % system life in years
Ifr=0.08; % The inflation rate
InR=0.04; % Interest rate 
S=0.1; % Per unit salvage value
Maximum=220; % Maximum power produced by one PV module

% Unit cost
U_PV=1*(1/5);% $/w
U_Inv_1=0.5*(1/5);% $/w, inverter 1
U_B=125*(1/5);% $/kwh
U_Con=0.5*(1/5);% $/w, converter
U_Inv_2=0.5*(1/5);% $/w, inverter 2

% Component's life in a year
L_PV=20;
L_B=5;
L_Con=10;
L_Inv=10;

%NR: number of replacements
NR_PV=floor((2*N-1)/(2*L_PV));
NR_B=floor((2*N-1)/(2*L_B));
NR_Con=floor((2*N-1)/(2*L_Con));
NR_Inv=floor((2*N-1)/(2*L_Inv));


%% Inital capitial Cost, IC

C_B=Cb;
C_PV=N_PV*Maximum;% Maximum power produced by one solar array at standered condtion  

C_inverter_1=C_PV;

maximum_discharge=min(0,min(Q));
maximum_discharge=-maximum_discharge;
C_inverter_2=maximum_discharge;

maximum_charge=max(0,max(Q));
C_converter=maximum_charge;
C_Con=C_converter; 


IC_PV=C_PV*U_PV;
IC_B=C_B*U_B;
IC_Con=C_Con*U_Con;
IC_Inv_1=C_inverter_1*U_Inv_1;
IC_Inv_2=C_inverter_2*U_Inv_2;
IC_Inv=IC_Inv_1+IC_Inv_2;

IC=(IC_PV+IC_B+IC_Con+IC_Inv)*1.4;% 0.4 is the civil cost

%% To find the maintenance cost, Mint
Xo_PV=0.01*IC_PV;
Xo_B=0.05*IC_B;
Xo_Inv=0*IC_Inv;
Xo_Con=0*IC_Con;

Mint_0=Xo_PV+Xo_B+Xo_Inv+Xo_Con;% maintenance of the first year

if Ifr==InR
    Mint=Mint_0*N;
else
Mint=Mint_0*(1+Ifr)/(InR-Ifr)*(1-((1+Ifr)/(1+InR))^N);
end

Mint_PV=Xo_PV*(1+Ifr)/(InR-Ifr)*(1-((1+Ifr)/(1+InR))^N);
Mint_B=Xo_B*(1+Ifr)/(InR-Ifr)*(1-((1+Ifr)/(1+InR))^N);
% Mint_Inv=0;
% Mint_Con=0;

%% To find cost of replacements, Rep

% factor=((1+Ifr)/(1+InR));
% syms k x
% F1 = symsum(factor^(N*k/(NR_PV+1)),k,1,NR_PV);
F1=0;
R_PV=IC_PV.*(1-S).*F1;


% syms k x
% F1 = double(symsum(factor^(N*k/(NR_B+1)),k,1,NR_B));
F1=4.4276;
R_B=IC_B*(1-S)*F1;

% syms k x
% F1 = double(symsum(factor^(N*k/(NR_Con+1)),k,1,NR_Con));
F1=1.4585;
R_Con=IC_Con*(1-S)*F1;
% 
% syms k x
% F1 = double(symsum(factor^(N*k/(NR_Inv+1)),k,1,NR_Inv));
F1=1.4585;
R_Inv=IC_Inv*(1-S)*F1;
R_Inv_1=IC_Inv_1*(1-S)*F1;
R_Inv_2=IC_Inv_2*(1-S)*F1;

% Rep=double(R_PV+R_B+R_Con+R_Inv);
Rep=(R_PV+R_B+R_Con+R_Inv);

%%
PV_LCC=(IC_PV+R_PV+Mint_PV)+(IC_Inv_1+R_Inv_1);
cb_LCC=(IC_B+R_B+Mint_B)+(IC_Con+R_Con)+(IC_Inv_2+R_Inv_2);

LCC=IC+Mint+Rep;
