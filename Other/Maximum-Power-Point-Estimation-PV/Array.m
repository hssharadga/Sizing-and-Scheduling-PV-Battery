% This script calculates the maximum power of an array at different operating conditions (G,T) and with different sizes (Ns, Np) using the searching method

% tic;
global Im
global Vm
global Isc_n
global  Voc_n
global Kv
global  Ki
global Nc_m_s
global  Nc_m_p
global  Gn
global T_ref
global n
global detla
global k
global q
global Vtn
global Vt
global  an
global  a
global G
global T
global Ns
global Np
%% Manufacturer Datasheet
Nc_m_s=54; % Number of cells connected in series in one module
Nc_m_p=1; % Number of cells connected in parallel in one module
Im=7.61;
Vm=26.3;
Isc_n=8.21;
Voc_n=32.9;
Kv=-0.123;
Ki=0.0032;
Gn=1000;
T_ref=25;
%% Number of cells
Ns_=Ns*Nc_m_s;  % Ns_==Number of cells connected in series in an array;   Ns==Number of PV modules connected in series in an array 
Np_=Np*Nc_m_p;  % Np_==Number of cells connected in parallel in an array; Np==Number of PV modules  connected in parallel in an array
%% Fixed
k=1.380650e-23;
q=1.602176e-19 ;
%%
Vt=k*(T+273.15)/q;
detla=T-T_ref;
a=n*Vt;

% Note: The parameters (Rsh, Io, Ipv)are calcualted assuming  Ns= 1 and Np=1; For example: Ns_=Ns*Nc_m_s,  Ns_=1*Nc_m_s=Nc_m_s
% The effect of Ns and Np will be only applied on the (I-V) equation which is written in the form of lambertw equation (See lines 65-70 in this script)

Rsh=Rshn*Gn/G;
Io=(Isc_n+Ki*detla+((Isc_n+Ki*detla)*Rs-(Nc_m_p/Nc_m_s)*(Voc_n+Kv*detla))/Rsh)/(Nc_m_p*(exp((Voc_n+Kv*detla)/(a*Nc_m_s))-exp((Isc_n+Ki*detla)*Rs/(a*Nc_m_p))));
Ipv=(Ipvn+Ki*detla)*G/Gn;

%% Iterations
vf=Voc_n*Ns;    % vf =  maximum value for the voltage
pp=vf*20;       % Number of searching steps
I = [];
V = [];
P = [];
Pmax_array=0;
for i=0:pp
    V (i+1)=i*vf/pp;
    VV=i*vf/pp;
    C=Rs/(a*Np_);
    D=VV/(a*Ns_);
    A=((Rsh+Rs)/Rsh)*(1/(-Np_*Io));
    B=(-Np_*Ipv-Np_*Io+(VV*Np_/(Ns_*Rsh)))*(1/(-Np_*Io));
    X=(-C/A)*(exp((D-(C*B/A))));
    II=-(1/C)*lambertw(X)-B/A;
% if (I(i+1)<=0)
%   I(i+1)=0
%   break
% end
    I(i+1)=II;
    P(i+1)=II*VV;
if P(i+1)> Pmax_array
Pmax_array=P(i+1);
Imax=I(i+1);
Vmax_array= V(i+1);
end
end
%% Display
% time=toc;
figure
plot (V,P,'r-', 'LineWidth',1.4)
ylim([0 inf])
% legend('N_s=8, N_p = 1','N_s=1, N_p = 8','N_s=4, N_p = 2','N_s=2, N_p = 4','N_s=1, N_p = 1')
xlabel('Voltage (V)')
ylabel ('Power')
title(['PV-Array (N_s = ',num2str(Ns), ', N_p = ',num2str(Np),')',' & Different-Operating-Conditions (G = ',num2str(G), ', T = ',num2str(T),')'])

shg

disp(['Pmax_array = ', num2str(Pmax_array)])
disp(['Vmax_array = ', num2str(Vmax_array)])

% disp(['time = ', num2str(time)])

