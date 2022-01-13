function E_total = energy_total(x)% x(1) is the titl angle and  x(2) is the azimuth angle of the array
global DNI
global DHI
global GHI
global zenth
global azimuth

Eb = zeros(length(DHI),1); %Initialize variable, Eb = Direct Beam

%% The angle of incidence (θ)calculations
temp=cosd(zenth).*cosd(x(1))+sind(zenth).*sind(x(1)).*cosd(azimuth-x(2));
temp(temp>1) = 1; temp(temp<-1) = -1;
incident_angle=acosd(temp);
%%

Eb(incident_angle<90) = DNI(incident_angle<90).*cosd(incident_angle(incident_angle<90));% Direct Beam

% Diffuse Radiation (Sky)
SkyDiffuse = DHI .*(1+ cosd(incident_angle)) .* 0.5;

% Diffuse Radiation (Ground)
albedo=.012*zenth-.04;
ground=GHI.*albedo.*(1-cosd(incident_angle))./2;
% albedo=0.2
% ground_=GHI.*albedo.*(1-cosd(incident_angle))./2


POA=Eb+SkyDiffuse+ground;
E_total=-sum(POA);% minimize (-cost) == maximize (cost)

