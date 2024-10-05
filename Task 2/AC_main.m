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

Y = Ybus;                 % Admittance Matrix
busd = case_struct.bus;     %bus
gend = case_struct.gen; %gen
branchd = case_struct.branch; %branch
BMva = case_struct.baseMVA;               %BMVA=100  

bus = busd(:,1);            % Bus Number
type = busd(:,2);           % Type of Bus
del = zeros(num, 1);          % Voltage Angle. Default is 0 degree
Pd = busd(:,3)/BMva;        % Pd
Qd = busd(:,4)/BMva;        % Qd

V = zeros(num,1)+1;       % Default Voltage = 1.0
Pg = zeros(num,1);        % generation active power
Qg = zeros(num,1);        % generation reactive power
Qmin = zeros(num,1);      % Min Reactive Power
Qmax = zeros(num,1);     % Max Reactive Power 
for i=1:size(gend,1)
    V(gend(i,1)) = gend(i,6);
    Pg(gend(i,1)) = gend(i,2);
    Qg(gend(i,1)) = gend(i,3);
    Qmax(gend(i,1)) = gend(i,4);
    Qmin(gend(i,1)) = gend(i,5);
end
Pg = Pg/BMva;        
Qg = Qg/BMva;        
Qmax = Qmax/BMva;
Qmin = Qmin/BMva;
     
P = Pg - Pd;               
Q = Qg - Qd;              
Psp = P;                    % P    (initial guess)  
Qsp = Q;                    % Q    (initial guess)
G = real(Y);                % Conductance
B = imag(Y);                % Susceptance

pv = find(type == 2 | type == 3);       % Index of PV Buses
pq = find(type == 1);                   % Index of PQ Buses
npv = length(pv);                       % Number of PV buses
npq = length(pq);                       % Number of PQ buses

% Newton-Raphson
Tol = 1;  % tolerance to be compared to accuracy limit
Iter = 1;           % iteration starting
while (Tol > 1e-10) % Accuracy limit. The smaller is value on right side, the more accurate is method
    P = zeros(num,1);
    Q = zeros(num,1);
    % Calculate P and Q
    for i = 1:num
        for k = 1:num
            P(i) = P(i) + V(i)* V(k)*(G(i,k)*cos(del(i)-del(k)) + B(i,k)*sin(del(i)-del(k)));
            Q(i) = Q(i) + V(i)* V(k)*(G(i,k)*sin(del(i)-del(k)) - B(i,k)*cos(del(i)-del(k)));
        end
    end

%     % Checking Q-limit. Optional
%     Num can be replaced to any value between 2 and num
%     if Iter <= num && Iter > 2
%         for n = 2:num
%             if type(n) == 2
%                 QG = Q(n)+Qd(n);
%                 if QG < Qmin(n)
%                     V(n) = V(n) + 0.01;
%                 elseif QG > Qmax(n)
%                     V(n) = V(n) - 0.01;
%                 end
%             end
%          end
%     end
    
    % Calculate change from specified value
    dPa = Psp-P;
    dQa = Qsp-Q;
    k = 1;
    dQ = zeros(npq,1);
    for i = 1:num
        if type(i) == 1
            dQ(k,1) = dQa(i);
            k = k+1;
        end
    end
    dP = dPa(2:num);
    M = [dP; dQ];       % Mismatch Vector
    
    % Jacobian
    % J1 - Derivative of Real Power Injections with Angles
    J1 = zeros(num-1,num-1);
    for i = 1:(num-1)
        m = i+1;
        for k = 1:(num-1)
            n = k+1;
            if n == m
                for n = 1:num
                    J1(i,k) = J1(i,k) + V(m)* V(n)*(-G(m,n)*sin(del(m)-del(n)) + B(m,n)*cos(del(m)-del(n)));
                end
                J1(i,k) = J1(i,k) - V(m)^2*B(m,m);
            else
                J1(i,k) = V(m)* V(n)*(G(m,n)*sin(del(m)-del(n)) - B(m,n)*cos(del(m)-del(n)));
            end
        end
    end
    
    % J2 - Derivative of Real Power Injections with V
    J2 = zeros(num-1,npq);
    for i = 1:(num-1)
        m = i+1;
        for k = 1:npq
            n = pq(k);
            if n == m
                for n = 1:num
                    J2(i,k) = J2(i,k) + V(n)*(G(m,n)*cos(del(m)-del(n)) + B(m,n)*sin(del(m)-del(n)));
                end
                J2(i,k) = J2(i,k) + V(m)*G(m,m);
            else
                J2(i,k) = V(m)*(G(m,n)*cos(del(m)-del(n)) + B(m,n)*sin(del(m)-del(n)));
            end
        end
    end
    
    % J3 - Derivative of Reactive Power Injections with Angles
    J3 = zeros(npq,num-1);
    for i = 1:npq
        m = pq(i);
        for k = 1:(num-1)
            n = k+1;
            if n == m
                for n = 1:num
                    J3(i,k) = J3(i,k) + V(m)* V(n)*(G(m,n)*cos(del(m)-del(n)) + B(m,n)*sin(del(m)-del(n)));
                end
                J3(i,k) = J3(i,k) - V(m)^2*G(m,m);
            else
                J3(i,k) = V(m)* V(n)*(-G(m,n)*cos(del(m)-del(n)) - B(m,n)*sin(del(m)-del(n)));
            end
        end
    end
    
    % J4 - Derivative of Reactive Power Injections with V
    J4 = zeros(npq,npq);
    for i = 1:npq
        m = pq(i);
        for k = 1:npq
            n = pq(k);
            if n == m
                for n = 1:num
                    J4(i,k) = J4(i,k) + V(n)*(G(m,n)*sin(del(m)-del(n)) - B(m,n)*cos(del(m)-del(n)));
                end
                J4(i,k) = J4(i,k) - V(m)*B(m,m);
            else
                J4(i,k) = V(m)*(G(m,n)*sin(del(m)-del(n)) - B(m,n)*cos(del(m)-del(n)));
            end
        end
    end
    
    J = [J1 J2; J3 J4];         % Jacobian Matrix
    
    X = J\M;                    % Correction Vector
    dTh = X(1:num-1);          % Change in Voltage Angle
    dV = X(num:end);           % Change in Voltage Magnitude
    
    % Update State Vectors (Voltage Angle & Magnitude)
    del(2:num) = dTh + del(2:num);
    k = 1;
    for i = 2:num
        if type(i) == 1
            V(i) = dV(k) + V(i);
            k = k+1;
        end
    end
    Iter = Iter + 1;
    Tol = max(abs(M));
end

% Call LoadFlow
[fb, tb, Pij, Qij] = loadflow(num,V,del,BMva);      