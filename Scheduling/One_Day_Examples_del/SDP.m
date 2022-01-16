% This function is used to calcaute the Future Cost (cost-to-go)
function [VALUE]=SDP(Load_Forecast, PV_Forecast)
global Length_controls
global Length_Es_states
global Length_peak_states
global Cb
global per_Load
global per_PV
global horizon
global T
global res1
global res2
global controls
global rate_max
global rate
global Es_states
global peak_states
global eta

VALUE=zeros(horizon+1,Length_Es_states,Length_peak_states);  %% Bellman Function

  for i=1:Length_peak_states
      peak=(i-1)*res2;
      VALUE(horizon+1,:,i)= peak*rate_max; % Final value = Fees on the peak value (horizon+1 is the end of the horizon)
  end
  

  %% loop backward in time 
  for t=flip(T)
 
      Time=t % Display the time step the calculation is being done for
      
    for k1=1:Length_Es_states
        Es=Es_states(k1)*res1;
        
        for k2=1:Length_peak_states
            Peak=peak_states(k2)*res2;
            locmin=zeros(10,10);%% Bellman value per uncertainty
            
            for w=1:10 %% Load scenarios (10 scenarios at every time step)
                
                ratio1=per_Load(horizon);
                ratio2=ratio1{1,1};
                ratio=ratio2(:,t);
                Load=Load_Forecast(t)*ratio(w);

                  
                for  ww=1:10  %% PV scenarios (10 scenarios at every time step)
                    
                    ratio1=per_PV(horizon);
                    ratio2=ratio1{1,1};
                    ratio_=ratio2(:,t);
                    PV=PV_Forecast(t)*ratio_(ww);

                    total_cost=[];
                    
                    for j=1:Length_controls %% Loop on control
                        u = controls(1,j);
                        Es_=Es+Cb*u;
                        grid=Load-PV+Cb*max(u*eta,u/eta);
                        grid_corrected=max(grid,0);
                        penalty=1/eps*((Es_>Cb)+(Es_<0)); %%penalty when the constraints are not respected
                        Es_=max(0,min(Cb,Es_)); %% effective state
                        Peak_new=max(Peak,grid);
                        
                        
                        ins_Cost=(grid_corrected)*rate;
                        
                        future_cost=VALUE(t+1,round(Es_/res1)+1,round(Peak_new/res2)+1);
                        total_cost(j)=ins_Cost+future_cost+penalty;  
                    end
                    total_cost_opt=min(total_cost);% find the minmum possible future cost
                    
                    locmin(w,ww)=total_cost_opt;
                                    
                  end  
                     
              end
              XX=sum(sum(locmin))*0.01;% 0.01 = 0.1 *  0.1 (0.1 = the propaibility of one scenario (1 out 10 scenarios) for both PV/load )
              VALUE(t,k1,k2)=XX;%% expectation
        end
    end
  end

end
