%% EE3123-2021

% info
% main function to obtain the cascading results

% dependent functions provided:
% selec_mpopt
% trig_lines
% find_subnetworks
% update_network
% check_overload
% scale_power_inj

% functions by yourself
% runpf: the power flow calculation

% required output
% record the outage lines in each iteration time step

% install matpower toolbox
% addpath ./sr
% addpath ./sr/matpower7.1
% install_matpower.m

%% initialize MATPOWER case struct parameter

define_constants; % define constants for matpower 

%% load case

% init power flow
init_mpc = loadcase('case118');
init_mpc = debug_case(init_mpc); % delete the duplicated components

%% run the initial power flow

mpopt = selec_mpopt('AC');
init_mpc = runpf(init_mpc, mpopt); %save it as a variable results

%% initialize the line capacity
% based on the initial power flow

flow_max_rate = 1.2;

% apparent power
S_branch = ((sqrt((init_mpc.branch(:, PF)).^2+(init_mpc.branch(:, QF)).^2)+sqrt((init_mpc.branch(:, PT)).^2+(init_mpc.branch(:, QT)).^2))/2);
init_mpc.branch(:, RATE_A) = abs(S_branch)* flow_max_rate;

%% initialize info for the iteration

mpc = init_mpc;

% record the initial outlines
t = 1;
outlines = mpc.branch(:,11);
mpc.outlines(:, t) = outlines;

%% apply initial failures

% N-1
%failure_set = [93]; 
% % N-2
%failure_set = [93, 65]; 
% % N-3
%failure_set = [23, 93, 102];

[mpc, outlines] = trig_lines(mpc, failure_set);
flag = 1; % flag to stop the iteration

%% start iteration
history_lines = [];
history_time = [];
while flag == 1

    [mpc_array, mpc] = find_subnetworks(mpc);
        
    for k = 1: length(mpc_array)
        
        mpc_subnet = mpc_array{k};

        %% write your codes accoding to the flowchart here!!!
% If have at least one in-service  generator
% 1) to detect whether a subnetwork must have  a  generator 
% 2) adjust power balance
% 3) run the power flow calculation
% 
% If have no in-service
% 1)set all current on buses , branches to be zero
       if (isempty(mpc_subnet.gen()))
            mpc_subnet = clear_net(mpc_subnet); %shut down the subnetwork with no generators or almost no loads
       else
        mpc_subnet=distri_slack(mpc_subnet);
        
        %temporary variable
        temp_subnet = mpc_subnet; %Store temp subnet
        mpc_subnet = Cal_AC_pf(temp_subnet); %make Newton-Raphson method converge

        end
        mpc = update_network(mpc, mpc_subnet);
    end % end of if (subnet has generator)

    %---------------------update the network----------------
    %mpc = update_network(mpc, mpc_subnet);

    %% write your codes accoding to the flowchart here!!!
    %---------------------cascade propagation----------------

    %------loop stop conditions: there is no more overloaded line ---------
    t=t+1; %update time
    [max_overload_line, overload_lines]=check_overload(mpc);
    if (isempty(overload_lines)) %no overload components
        flag=0;
    else
        history_lines(end+1) = max_overload_line; %store history of path of failure
        history_time(end+1) = t; %%store history of time step
    end
    failure_set = max_overload_line;
    [mpc, outlines]=trig_lines(mpc, failure_set);
end


%display output
history_data = [history_lines', history_time'];
disp('Finished');
disp('The history of affected lines and time excluding initial set');
disp('|Line | Time|');
disp(history_data);
all_lines = [];
for i=1:length(outlines)
    if outlines(i)~=1
        all_lines(end+1) = i;
    end
end
disp('All affected lines including initial set (sorted array)');
disp('Line');
disp(all_lines');



