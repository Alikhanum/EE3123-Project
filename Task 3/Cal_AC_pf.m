function results = Cal_AC_pf(mpc)

define_constants; %define constants for matpower 
mpopt = mpoption( 'out.all', 0, 'pf.nr.max_it', 100);

tic
[results] = runpf(mpc, mpopt); %save it as a variable results
toc

% % mpc.gen(find(mpc.gen(:,1)==find(mpc.bus(:,2)==3)),2) = results.gen(find(mpc.gen(:,1)==find(mpc.bus(:,2)==3)),2); 
% to equate the slack bus with the initial output

while results.success ~=1
    if sum(mpc.bus(:,3))>0.1 %if there is load to shed (assuming the min. load is 0.1 p.u. to prevent infinite loop)
        warning('Base Case load flow is not converged. 1% Load shedding will be performed...') 
        mpc= scale_power_inj(mpc, 0.01); 
        [results] = runpf(mpc, mpopt);
    else %there is no load to shed
        warning('There is no load to shed. Check base case data...') 
        results.success =1; %break the while loop
        results = clear_net(results);
    end
end