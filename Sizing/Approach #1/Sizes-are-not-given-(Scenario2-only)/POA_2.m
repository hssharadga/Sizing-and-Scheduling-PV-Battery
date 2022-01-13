function  []= POA_2(x) % Calculate POA and Ee (Effective irradiance)
global DNI;
global DHI;
global GHI;
global zenth;
global azimuth;
global AMa;

% x: x(1) is the title angle of PV array and x(2) is the azimuth angle of PV array

%% Initiallize variable
Eb = zeros(length(DHI),1);% Direct Beam
Ediff=zeros(length(DHI),1);
POA=zeros(length(DHI),1);

%% The angle of incidence (θ)calculations
temp=cosd(zenth).*cosd(x(1))+sind(zenth).*sind(x(1)).*cosd(azimuth-x(2));
temp(temp>1) = 1; temp(temp<-1) = -1;
incident_angle=acosd(temp);


%% POA calculations
Eb(incident_angle<90)=DNI(incident_angle<90).*cosd(incident_angle(incident_angle<90));% Direct Beam
Ediff(incident_angle<90)=DHI(incident_angle<90) .*(1+ cosd(incident_angle(incident_angle<90))) .* 0.5+GHI(incident_angle<90).*(0.012.*zenth(incident_angle<90)-.04).*(1-cosd(incident_angle(incident_angle<90)))./2;% Diffuse Radiation (Sky&Ground) 
POA(incident_angle<90) = Eb(incident_angle<90)+Ediff(incident_angle<90);
csvwrite("POA.csv",POA);




%% Effective irradiance calculations: 
%See PV_LIB Toolbox at "https://pvpmc.sandia.gov/PVLIB_Matlab_Help/" then go to "Example Scripts" then go to "PVL_TestScript1"


SF=0.98;% Soiling reduces the amount of light reaching the array. We will assume that soling levels are 2%.

AOI=incident_angle;% Angle of incidence


% Parameters are different from module to another
% Current module: Canadian Solar CS5P-220M, see Row 124 in the excel sheet (located in this folder) of Sandia lab: SandiaModuleDatabase_20120925
% Or go to  "https://pvpmc.sandia.gov/PVLIB_Matlab_Help/" then go to "pvl_sapmmoduledb"
% or install the PVLIB toolbox at "https://pvpmc.sandia.gov/applications/pv_lib-toolbox/" and see the "Documentation for PV_LIB Toolbox for Matlab"
a=[-6.9304e-05,0.0017,-0.0158,0.0681,0.9284]; % [A4, A3, A2, A1, A0]
b=[-1.3590e-09,2.1120e-07,-1.2460e-05,3.1030e-04,-0.0024,1]; % [B5, B4, B3, B2, B1, B0]
fd=1;

% Calculations
E0 = 1000; %Reference irradiance (1000 W/m^2)
F1 = max(0,polyval(a,AMa)); %Spectral loss function
F2 = max(0,polyval(b,AOI)); % Angle of incidence loss function
Ee = F1.*((Eb.*F2+fd.*Ediff)./E0).*SF; %Effective irradiance
Ee(isnan(Ee))=0; % Set any NaNs to zero
%%

csvwrite("Ee.csv",Ee);