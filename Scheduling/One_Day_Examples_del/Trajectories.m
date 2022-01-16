% Trajectories simulations 

function [u,Es_all,Peak_all,c,grid]=Trajectories(E0)

global T
global rate_max
  Es=E0;
  u=[];
  grid=[];
  Es_all=[];
  Peak=0;
  Peak_all=[];
  c=0; % c is total cost
 
  for t=T
    [u_opt,Es_opt,Peak_new_opt,ins_Cost_opt,grid_opt]=SDP_policy(t,Es,Peak);
    u=[u,u_opt];
    Es_all=[Es_all,Es_opt];
    Es=Es_opt;
    Peak_all=[Peak_all,Peak_new_opt];
    Peak=Peak_new_opt;
    grid=[grid,grid_opt];

    c=c+ ins_Cost_opt; 
  end
  final_cost=rate_max*Peak_all(end);
  c=c+final_cost; % cost of one scenario since we make c zero every time
end
