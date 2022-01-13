% Compare SAM software and solar book calculations for the solar angles
% we use SAM software to extrace the waether data  (https://sam.nrel.gov/)

latitude=30.61;
t=0:0.5:23.5;

CC = readtable('Data.csv'); % from SAM
CC=CC{1:48,:};
% DNI=CC(:,1)
% DHI=CC(:,2)
% GHI=CC(:,3)
Zenith=CC(:,4);
azimuth=CC(:,5);

C = readtable('Time.csv');
C=C{:,:};
Month=C(:,1);
Day=C(:,2);
Hour=C(:,3);
Minutes=C(:,4);

Hour_=Hour+Minutes/60;
Day=Day+212+20; % Table 1.6.1 at Solar Book: "J. A. Duffie, Solar Engineering of Thermal Processes, -John A. Duffie, William A. Beckman. 1991", This one should be modified for year. This code is for August 20 only.
Day_=Day+(Hour_)/24;
Declination=23.45*sind(360/365*(Day_+284)); % See Equation 1.6.1 at Solar Book mentioned above

% hour angle
w=15*(Hour_-12);

% From Solar Book Equation 1.6.5
Zenith_=acosd(cosd(latitude).*cosd(Declination).*cosd(w)+sind(latitude).*sind(Declination));

yyaxis right
plot(t,Zenith_,'r--')
hold on
plot(t,Zenith,'rs')
ylim([0,160])
ylabel('Zenith Angle (\theta_z)')


lll=length(Zenith_);

% Solar Book Equation 1.6.6g
j=tand(Declination)./tand(latitude);
wew=acosd(j);


% Solar Book Equation 1.6.6
C1=-1.*ones(lll,1);
C1(abs(w)<wew)=1;
C2=-1.*ones(lll,1);
C2(latitude*(latitude-Declination)>=0)=1;
C3=-1.*ones(lll,1);
C3(w>=0)=1;


LL=asind(sind(w).*cosd(Declination)./sind(Zenith_));
Azimuth_=C1.*C2.*LL+C3.*180.*(1-C1.*C2)./2; % Solar Book Equation 1.6.6a


% Convert the range from "-180:180"  to  "0:360"
Azimuth_(Azimuth_<0)=Azimuth_(Azimuth_<0)+360;


% Convert the solar book convention for the azimuth angle to the defintation of SAM
for i=1: length(Azimuth_)
    if Azimuth_(i)<=180 
Azimuth_(i)=Azimuth_(i)+180;
    else
Azimuth_(i)=Azimuth_(i)-180;
    end
end

    

yyaxis left

plot(t,azimuth,'ks')
hold on
plot(t,Azimuth_,'k--')
xlabel('Time (hr)')
ylabel('Azimuth Angle (\gamma_s)')
legend('SAM','Solar Book')

grid on
xlim([0,24]);
xticks(0:4:24);
yticks(0:60:360)
