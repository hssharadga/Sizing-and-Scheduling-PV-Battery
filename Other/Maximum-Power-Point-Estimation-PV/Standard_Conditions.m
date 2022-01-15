
%% Number of Searching Steps
pp=100;%% number of searching steps (tuning the voltage)
ppp=100;% number of searching steps (tuning the "n")
%%
% time0=tic;
global Im
global Vm
global Isc_n
global  Voc_n
global Kv
global  Ki
global Nc_m_s; 
global  Nc_m_p;
global  Gn
global T_ref
global n
global k
global q
global Vtn
global  a_n
global Rshn
global Rs
global Ipvn
global Ion

%% Manufacturer Datasheet
Nc_m_s=54; % Number of cells connected in series in one module
Nc_m_p=1; % Number of cells connected in parallel in one module
Pmax_=200.143;
Im=7.61;
Vm=26.3;
Isc_n=8.21;
Voc_n=32.9;
Kv=-0.123;
Ki=0.0032;

%% Fixed
Gn=1000;%%%%
T_ref=25;%%%
k=1.380650e-23;
q=1.602176e-19 ;
Vtn=k*(T_ref+273.15)/q;


%% Iterations

for j=1:1/ppp:2
j;
n=j;

I = [];
V = [];
P = [];
a_n=n*Vtn;

%% Solving nonlinear equation
fun = @Resistance;
x0 = [0.001];% Initial guess for Rs
xx = fsolve(fun,x0);
Rs=xx;
%%

% Note: The parameters at standard conditions(Rshn, Ion, Ipvn)are calcualted assuming  Ns= 1 and Np=1.
% For example: Ns_=Ns*Nc_m_s,  Ns_=1*Nc_m_s=Nc_m_s

exp_voc=exp(Voc_n/((a_n*Nc_m_s)))-1;
exp_Isc=exp(Rs*Isc_n/((a_n*Nc_m_p)))-1;
exp_m=exp((Vm/(a_n*Nc_m_s))+Im*Rs/(a_n*Nc_m_p))-1;
Rshn=(Isc_n*Rs-(Nc_m_p/Nc_m_s)*Voc_n+(-Im*Rs-Vm*(Nc_m_p/Nc_m_s)+(Nc_m_p/Nc_m_s)*Voc_n)/((exp_voc-exp_m)/(exp_voc-exp_Isc)))/((Im/(((exp_voc)-(exp_m))/((exp_voc)-exp_Isc)))-Isc_n);
Ion=(Isc_n+(Isc_n*Rs-Voc_n*Nc_m_p/Nc_m_s)/Rshn)/(Nc_m_p*(exp_voc-exp_Isc)); 
Ipvn=Ion*(exp_voc)+Voc_n/(Nc_m_s*Rshn);

vf=Voc_n;% vf =  maximum value for the voltage
Pmax=0;
for i=0:pp
    V (i+1)=i*vf/pp;
    VV=i*vf/pp;
    C=Rs/(a_n*Nc_m_p);
    D=VV/(a_n*Nc_m_s);
    A=((Rshn+Rs)/Rshn)*(1/(-Nc_m_p*Ion));
    B=(-Nc_m_p*Ipvn-Nc_m_p*Ion+(VV*Nc_m_p/(Nc_m_s*Rshn)))*(1/(-Nc_m_p*Ion));
    X=(-C/A)*(exp((D-(C*B/A))));
    II=-(1/C)*lambertw(X)-B/A;%% II is the current

    I(i+1)=II;

    P(i+1)=II*VV;

if P(i+1)> Pmax
Pmax=P(i+1);% updating the maximum power that has been found
Imax=I(i+1);
Vmax= V(i+1);
end

end
if abs(Pmax_-Pmax)<0.01; % Validating the solution/iteration
    disp(['coverage with tolerance ',num2str(abs(Pmax_-Pmax)), ', Pmax = ',num2str(Pmax) ])
    break
end
end

%% Display 
% time1=toc;
% time=time1-time0;
% plot (V,P,'g--', 'LineWidth',1.4)
plot (V,I,'r-', 'LineWidth',1.4)
ylim([0 inf])

% Comparing with experimental data
hold on
load Experimental_Data.mat
plot (x1000,y1000,'bo','LineWidth',1.2)
% disp(['time = ', num2str(time)])
title('Standard-Conditions & One-PV-Module')

xlabel('Voltage (V)')
ylabel ('Current (I)')
shg
legend('Theoretical','Experimental')
