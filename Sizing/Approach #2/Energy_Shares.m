%% Energy Shares (See Energy Shares section in the sizng paper)


AA=0;BB=0;CC=0;DD=0;EE=0;FF=0;

for i=1:8640; % 8640 hrs in a year
    

i % day number
if ((Q(i)<=0) && (grid_(i)>=0)) % Case #2
    syms A B C D E F 
    eqn1 = A+B+C == N_PV*PV(i)/1000;
    eqn2 = D+E-B == grid_(i)/1000;
    eqn3 = A+E-F == Q(i)/1000;
    eqn4 = A == 0;
    eqn5 = E == 0;
    eqn6 = B == 0;
    Case=2;
    [Aa,Bb] = equationsToMatrix([eqn1, eqn2, eqn3, eqn4, eqn5, eqn6], [ A, B, C, D, E, F]);
    X = Aa\Bb;
    AA=AA+X(1);BB=BB+X(2);CC=CC+X(3);DD=DD+X(4);EE=EE+X(5);FF=FF+X(6);


elseif ((Q(i)<=0) && (grid_(i)<=0))% Case #1
    syms A B C D E F 
    eqn1 = A+B+C == N_PV*PV(i)/1000;
    eqn2 = D+E-B == grid_(i)/1000;
    eqn3 = A+E-F == Q(i)/1000;
    eqn4 = A == 0;
    eqn5 = E == 0;
    eqn6 = D == 0;
    Case=3;
    [Aa,Bb] = equationsToMatrix([eqn1, eqn2, eqn3, eqn4, eqn5, eqn6], [ A, B, C, D, E, F]);
    X = Aa\Bb;
    AA=AA+X(1);BB=BB+X(2);CC=CC+X(3);DD=DD+X(4);EE=EE+X(5);FF=FF+X(6);

    
elseif ((Q(i)>=0) && (grid_(i)<=0))% Case #3
    syms A B C D E F 
    eqn1 = A+B+C == N_PV*PV(i)/1000;
    eqn2 = D+E-B == grid_(i)/1000;
    eqn3 = A+E-F == Q(i)/1000;
    eqn4 = F == 0;
    eqn5 = E == 0;
    eqn6 = D ==0;
    Case=4;
    [Aa,Bb] = equationsToMatrix([eqn1, eqn2, eqn3, eqn4, eqn5, eqn6], [ A, B, C, D, E, F]);
    X = Aa\Bb;
    AA=AA+X(1);BB=BB+X(2);CC=CC+X(3);DD=DD+X(4);EE=EE+X(5);FF=FF+X(6);
end


if ((Q(i)>=0) && (grid_(i)>=0))% Case #4
    syms A C D E 
    eqn1 = A+C == N_PV*PV(i)/1000;
    eqn2 = D+E == grid_(i)/1000;
    eqn3 = A+E == Q(i)/1000;
    if N_PV*PV(i)<Load(i)
        eqn4 = A ==0;
    elseif N_PV*PV(i)>=Load(i)
        
        eqn4 = D == 0;
    end
        
    [Aa,Bb] = equationsToMatrix([eqn1, eqn2, eqn3, eqn4], [ A, C, D, E]);
    X = Aa\Bb;
    AA=AA+X(1);CC=CC+X(2);DD=DD+X(3);EE=EE+X(4);
       
end


end


%%
double (AA/(AA+BB+CC))% Solar
double (BB/(AA+BB+CC))
double (CC/(AA+BB+CC))

double (EE/(EE+DD))% Grid

double(FF/(FF+CC+DD))% Load
double(DD/(FF+CC+DD))
double(CC/(FF+CC+DD))

double (AA/(EE+AA))% Battery Charging
