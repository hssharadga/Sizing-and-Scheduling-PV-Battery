function f = Resistance(x)

global Im
global Vm
global Isc_n
global  Voc_n
global Nc_m_s
global  Nc_m_p
global  a_n

% See Equation 28 at (Hussein Sharadga et. al, 'A Fast and Accurate Single-Diode Model for Photovoltaic Design', IEEE Journal of Emerging and Selected Topics in Power Electronics, DOI: 10.1109/JESTPE.2020.3016635)
f=(Vm*Nc_m_p./Nc_m_s-Im*x+(Vm./(a_n*Nc_m_s)-(Im*x./(a_n*Nc_m_p)))*(Isc_n*x-Voc_n*Nc_m_p./Nc_m_s)*(exp(Vm./(a_n*Nc_m_s)+Im*x./(a_n*Nc_m_p))./((exp(Voc_n./((a_n*Nc_m_s)))-1)-(exp(x*Isc_n./((a_n*Nc_m_p)))-1))))*(((Im./((((exp(Voc_n./((a_n*Nc_m_s)))-1))-((exp((Vm./(a_n*Nc_m_s))+Im*x./(a_n*Nc_m_p))-1)))./(((exp(Voc_n./((a_n*Nc_m_s)))-1))-(exp(x*Isc_n./((a_n*Nc_m_p)))-1))))-Isc_n))-((Isc_n*x-(Nc_m_p./Nc_m_s)*Voc_n+(-Im*x-Vm*(Nc_m_p./Nc_m_s)+(Nc_m_p./Nc_m_s)*Voc_n)./(((exp(Voc_n./((a_n*Nc_m_s)))-1)-(exp((Vm./(a_n*Nc_m_s))+Im*x./(a_n*Nc_m_p))-1))./((exp(Voc_n./((a_n*Nc_m_s)))-1)-(exp(x*Isc_n./((a_n*Nc_m_p)))-1)))))*(-Vm*Isc_n ./(a_n*Nc_m_s)*exp(Vm./(a_n*Nc_m_s)+Im*x./(a_n*Nc_m_p))./((exp(Voc_n./((a_n*Nc_m_s)))-1)-(exp(x*Isc_n./((a_n*Nc_m_p)))-1))+Im*(1+x*Isc_n./a_n*exp(Vm./(a_n*Nc_m_s)+Im*x./(a_n*Nc_m_p))./((exp(Voc_n./((a_n*Nc_m_s)))-1)-(exp(x*Isc_n./((a_n*Nc_m_p)))-1))));


