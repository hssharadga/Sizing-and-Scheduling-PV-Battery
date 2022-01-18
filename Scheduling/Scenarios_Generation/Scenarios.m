%  Converting the Scenarios to 10 Scenarios by extracting 10 equally-distributed percentiles

y=(yy./forecasted);
y1=[];
for i=1:(length(y)/hrs)
y1_=y(step+(i-1)*hrs);   
y1=[y1,y1_];
end
y1(y1==inf)=[];
figure
plot(y1,'r*')
ylim([0,2])
ylabel('Real / forecasted')
xlabel('Day #')

% 10 equally-distributed percentiles
j=linspace(10,100,10)-5;
per = prctile(y1,j)

figure
plot(per,'r*')
xlabel('Percentile [10%]')
ylabel('Real / forecasted')
grid on
ylim([0,1.5])

