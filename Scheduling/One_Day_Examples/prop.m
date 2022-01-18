% Returns percentiles of results, percentiles represent the scenarios in
% this work, scenarios will be used by SDP or SDDP (SDDP: Stochastic Dual Dynamic Programming).

function per= prop(hrs,H,stepp)
global yy
global forecasted
y=(yy./forecasted);

y1=[];
for i=1:(length(y)/hrs)
y1_=y((hrs-H+stepp)+(i-1)*hrs);   
y1=[y1,y1_];
end
y1(y1==inf)=[] ;

j=linspace(10,100,10)-5;
per = prctile(y1,j);         % prctile: Returns percentiles 

