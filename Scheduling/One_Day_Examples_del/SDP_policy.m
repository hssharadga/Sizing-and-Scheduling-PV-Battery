%% optimal policy
% This function  is used to update the descion every time step (Forward simulations)

function [u_opt,Es_opt,Peak_new_opt,ins_Cost_opt,grid_opt]=SDP_policy(t,Es, Peak)
global PV_real_given_day_
global Load_real_given_day_
global V
global eta
global Length_controls
global Cb
global res1
global res2
global N_PV
global controls
global rate


% Initialize
VALUE=V;           % Future cost
opt =  1/eps;      % Optimal value
u_opt = 0;         % Optimal control

for j=1:Length_controls %% Loop on control
    u = controls(1,j);
    Es_=Es+Cb*u;
    grid=Load_real_given_day_(t)/1000-N_PV*PV_real_given_day_(t)/1000+Cb*max(u*eta,u/eta);
    grid_corrected=max(grid,0);
    penalty=1/eps*((Es_>Cb)+(Es_<0));  % penalty when the constraints are not respected
    Es_=max(0,min(Cb,Es_));            % effective state
    Peak_new=max(Peak,grid_corrected);
    ins_Cost=grid_corrected*rate;
    future_cost=VALUE(t+1,round(Es_/res1)+1,round(Peak_new/res2)+1);
    total_cost=ins_Cost+future_cost+penalty;

            
    if (total_cost < opt) % If yes update the optimal descion
        
        % Parameters corresponding to the optimal control
        u_opt = u;                 % optimal control
        opt = total_cost ;         %...
        ins_Cost_opt=ins_Cost;
        Es_opt=Es_;
        grid_opt=grid_corrected;
        Peak_new_opt=Peak_new;
        
    end

end

end