num = input('Enter the bus system no.: (14 or 118): '); %choose the case
while num ~= 14 && num ~= 118
    fprintf('Invalid Input try again\n');
    num = input('Enter the bus system no.: (14 or 118): ');
end
switch num
    case 14
        case_struct=case14;
        load('data_Ybus_case14.mat');
    case 118
        case_struct=case118;
        load('data_Ybus_case118.mat');
end

[Y] = -imag(Ybus);           % Admittance Matrix
busd = case_struct.bus;       %  get busdatas
gend = case_struct.gen;
branchd = case_struct.branch; % branch
BMva = case_struct.baseMVA;               %100 MVA  

bus = busd(:,1);            % bus data
type = busd(:,2);           % Type of Bus
Pd = busd(:,3)/BMva;      % Pd
Pg = zeros(num,1);        % Get Pg, 0 is default
for i=1:size(gend,1)
    Pg(gend(i,1)) = gend(i,2);
end
Pg = Pg/BMva;               %pu
y = 1*Y; y(1,:) = []; y(:,1) = []; % delete first row and column of the admitance matrix
P_neta = Pg - Pd; %net real power
P_neta(1) = []; % remove first P
del = abs(y^-1)*P_neta; % compute the angles of the nodes
del = [0; del]; % first bus angle = 0
Pi = Y*del*BMva;
V = ones(length(busd(:,1)),1); % voltage of buses = 1
FromNode = branchd(:,1);          %from node
ToNode = branchd(:,2);         % to nodes
% define active power flows
for k = 1:length(FromNode)
    Pij(k) = abs(Y(FromNode(k),ToNode(k)))*(del(FromNode(k))-del(ToNode(k)));
end
for k = 1:length(FromNode)
    Pji(k) = abs(Y(ToNode(k),FromNode(k)))*(del(ToNode(k))-del(FromNode(k)));
end
Del=(180/pi)*del; % angle to degree





%display the answer
Pireserve = Pi; % store all values including negative
Pi = max(Pi,0); % leave only positive values
Pij = Pij*BMva;
Pji = Pji*BMva;
Pd=Pd*BMva;
Qi = zeros(num,1);  %reactive power = 0
Qg = zeros(num,1);  
Qd = zeros(num,1);  
Qij = zeros(length(FromNode),1);
Lpij = zeros(length(FromNode),1);  %line losses are 0
Lqij = zeros(length(FromNode),1); %line losses are 0
disp('#########################################################################################');
disp('-----------------------------------------------------------------------------------------');
disp('                              DC Powerflow Analysis ');
disp('-----------------------------------------------------------------------------------------');
disp('| Bus |    V   |  Angle  |  Generation (Real) |       Load (Real)    |');
disp('| No  |   pu   |  Degree |    MW   |  Mvar    |     MW     |  MVar | ');
for m = 1:length(bus)
    disp('-----------------------------------------------------------------------------------------');
    fprintf('%3g', m); fprintf('  %8.4f', V(m)); fprintf('   %8.4f', Del(m));
    fprintf('  %8.2f', Pi(m)); fprintf('   %8.2f', Qg(m)); 
    fprintf('  %8.2f', Pd(m)); fprintf('   %8.2f', Qd(m)); fprintf('\n');
end
disp('-----------------------------------------------------------------------------------------');
fprintf(' Total                  ');fprintf('  %8.3f', sum(Pi)); fprintf('   %8.3f', sum(Qi+Qd));
fprintf('  %8.3f', sum(Pd)); fprintf('   %8.3f', sum(Qd)); fprintf('\n');
disp('-----------------------------------------------------------------------------------------');
disp('#########################################################################################');

disp('-------------------------------------------------------------------------------------');
disp('                              Line Flow and Losses ');
disp('-------------------------------------------------------------------------------------');
disp('|From|To |    P    |    Q     | From| To |    P     |   Q     |      Line Loss      |');
disp('|Bus |Bus|   MW    |   MVar   | Bus | Bus|    MW    |  MVar   |     MW   |    MVar  |');
for m = 1:length(FromNode)
    p = FromNode(m); q = ToNode(m);
    disp('-------------------------------------------------------------------------------------');
    fprintf('%4g', p); fprintf('%4g', q); fprintf('  %8.2f', Pij(m)); fprintf('   %8.2f', Qij(m)); 
    fprintf('   %4g', q); fprintf('%4g', p); fprintf('   %8.2f', Pji(m)); fprintf('   %8.2f', Qij(m));
    fprintf('  %8.2f', Lpij(m)); fprintf('   %8.2f', Lqij(m));
    fprintf('\n');
end
disp('-------------------------------------------------------------------------------------');
fprintf('   Total Loss                                                 ');
fprintf('  %8.3f', sum(Lpij)); fprintf('   %8.3f', sum(Lqij));  fprintf('\n');
disp('-------------------------------------------------------------------------------------');
disp('#####################################################################################');