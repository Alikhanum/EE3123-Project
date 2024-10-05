function [fb, tb, Pij, Qij] = loadflow(num,V,del,BMva)
switch num
    case 14
        case_struct=case14;
        load('data_Ybus_case14.mat');
    case 118
        case_struct=case118;
        load('data_Ybus_case118.mat');
end
Y = Ybus;           % Admittance Matrix
busd = case_struct.bus;  
branchd = case_struct.branch;
BMva = case_struct.baseMVA;                 


Vm = pol2rect(V,del);       % polar to rectangular
Del = 180/pi*del;           % Angle To Degree
fb = branchd(:,1);            
tb = branchd(:,2);            
nl = length(fb);            % No. of Branches
Pd = busd(:,3)/BMva;        
Qd = busd(:,4)/BMva;        

nb = num;            % Number of buses
Iij = zeros(nb,nb);
Sij = zeros(nb,nb);


I = Y*Vm; %current
for m = 1:nl
    p = fb(m); q = tb(m);
     Iij(p,q) = -(Vm(p) - Vm(q))*Y(p,q); % Y(m,n) = -y(m,n)
     Iij(q,p) = -Iij(p,q); %calculate current for each line
end

 % Line Power Flows
for m = 1:nb
    for n = 1:nb
        if m ~= n
            Sij(m,n) = Vm(m)*conj(Iij(m,n))*BMva;
        end
    end
end
Pij = real(Sij);
Qij = imag(Sij);
 
% Line Losses
Lij = zeros(nl,1);
for m = 1:nl
    p = fb(m); q = tb(m);
    Lij(m) = Sij(p,q) + Sij(q,p);
end
Lpij = real(Lij); %MW line losses
Lqij = imag(Lij); %MVar line losses
 

Si = conj(I).*Vm; %complex power
Pi = real(Si); %active power
Qi = imag(Si); %reactive power
Pg = (Pi+Pd); %generation active power
Pg = Pg * BMva; 
Pireserve = Pi; % store all values including negative
Pi = max(Pi,0); % leave only positive values
Pi = Pi * BMva; %injection active power
Pd = Pd * BMva; %load active power
Qg = (Qi+Qd);  % generation reactiv epowre
Qg = Qg * BMva;
Qireserve = Qi; % store all values including negative
Qi = max(Qi,0); % leave only positive values
Qi = Qi * BMva; %injection reactive power
Qd = Qd * BMva; %load reactive power
 
disp('#########################################################################################');
disp('-----------------------------------------------------------------------------------------');
disp('                              Newton Raphson Powerflow Analysis ');
disp('-----------------------------------------------------------------------------------------');
disp('| Bus |    V   |  Angle  |     Injection      |     Generation     |          Load      |');
disp('| No  |   pu   |  Degree |    MW   |   MVar   |    MW   |  Mvar    |     MW     |  MVar | ');
for m = 1:nb
    disp('-----------------------------------------------------------------------------------------');
    fprintf('%3g', m); fprintf('  %8.4f', V(m)); fprintf('   %8.4f', Del(m));
    fprintf('  %8.2f', Pi(m)); fprintf('   %8.2f', Qi(m)); 
    fprintf('  %8.2f', Pg(m)); fprintf('   %8.2f', Qg(m)); 
    fprintf('  %8.2f', Pd(m)); fprintf('   %8.2f', Qd(m)); fprintf('\n');
end
disp('-----------------------------------------------------------------------------------------');
fprintf(' Total                  ');fprintf('  %8.3f', sum(Pi)); fprintf('   %8.3f', sum(Qi)); 
fprintf('  %8.3f', sum(Pg)); fprintf('   %8.3f', sum(Qg));
fprintf('  %8.3f', sum(Pd)); fprintf('   %8.3f', sum(Qd)); fprintf('\n');
disp('-----------------------------------------------------------------------------------------');
disp('#########################################################################################');

disp('-------------------------------------------------------------------------------------');
disp('                              Line Flow and Losses ');
disp('-------------------------------------------------------------------------------------');
disp('|From|To |    P    |    Q     | From| To |    P     |   Q     |      Line Loss      |');
disp('|Bus |Bus|   MW    |   MVar   | Bus | Bus|    MW    |  MVar   |     MW   |    MVar  |');
for m = 1:nl
    p = fb(m); q = tb(m);
    disp('-------------------------------------------------------------------------------------');
    fprintf('%4g', p); fprintf('%4g', q); fprintf('  %8.2f', Pij(p,q)); fprintf('   %8.2f', Qij(p,q)); 
    fprintf('   %4g', q); fprintf('%4g', p); fprintf('   %8.2f', Pij(q,p)); fprintf('   %8.2f', Qij(q,p));
    fprintf('  %8.2f', Lpij(m)); fprintf('   %8.2f', Lqij(m));
    fprintf('\n');
end
disp('-------------------------------------------------------------------------------------');
fprintf('   Total Loss                                                 ');
fprintf('  %8.3f', sum(Lpij)); fprintf('   %8.3f', sum(Lqij));  fprintf('\n');
disp('-------------------------------------------------------------------------------------');
disp('#####################################################################################');