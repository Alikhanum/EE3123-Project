%% EE3123-2021

% info
% update network info; into the initial data size
% 

% input:
% mpc
% mpc_subnet: the subnetwork after run the power flow

% output:
% mpc_array: subnetworks, with >1 nodes
% mpc: updated mpc for single nodes

%%
function mpc = update_network(mpc, mpc_subnet)

bus_size = size(mpc.bus, 1);
gen_size = size(mpc.gen, 1);
branch_size = size(mpc.branch,1);
gencost_size = size(mpc.gencost,1);

%% for bus
results_bus = mpc_subnet.bus;
finish_bus = zeros(bus_size, 1);
for i = 1:size(results_bus,1)

	results_bus_id = results_bus(i, 1);
	 
	for j = 1:bus_size
		results_temp_bus_id = mpc.bus(j, 1);
		if results_temp_bus_id == results_bus_id && finish_bus(j) == 0
			mpc.bus(j, :) = results_bus(i, :);
            finish_bus(j) = 1;
		end
	end
end


%% for gen
results_gen = mpc_subnet.gen;
finish_gen = zeros(gen_size, 1);
for i = 1:size(results_gen,1)

	results_gen_id = results_gen(i, 1);
	 
	for j = 1:gen_size
		results_temp_gen_id = mpc.gen(j, 1);
		if results_temp_gen_id == results_gen_id && finish_gen(j) == 0
			mpc.gen(j, :) = results_gen(i, :);
            finish_gen(j) = 1;
		end
	end
end

%% for branch
results_branch = mpc_subnet.branch;
finish_branch = zeros(branch_size, 1);
%size_diff = size(results_branch, 2) - size(results_temp.branch, 2);
%results_temp.branch(:, end+1:end+2) = 0;

for i = 1:size(results_branch,1)

	results_branch_head = results_branch(i, 1);
	results_branch_tail = results_branch(i, 2);
	 
	for j = 1:branch_size
		results_temp_branch_head = mpc.branch(j, 1);
		results_temp_branch_tail = mpc.branch(j, 2);

		if results_temp_branch_head == results_branch_head && results_temp_branch_tail == results_branch_tail && ...
			finish_branch(j) == 0
			mpc.branch(j, :) = results_branch(i, :);
            finish_branch(j) = 1;
		end
	end
end

%% for gencost (id should follow generator)
results_gencost = mpc_subnet.gencost;
finish_gencost = zeros(gencost_size, 1); % gencost_size == gen_size IN mpc...

for i = 1:size(results_gencost,1)

	results_gen_id = results_gen(i, 1); % size_results_gen == size_results_gencost
	 
	for j = 1:gen_size
		results_temp_gen_id = mpc.gen(j, 1);
		if results_temp_gen_id == results_gen_id && finish_gencost(j) == 0
			mpc.gencost(j, :) = results_gencost(i, :);
            finish_gencost(j) =1;
		end
	end
end