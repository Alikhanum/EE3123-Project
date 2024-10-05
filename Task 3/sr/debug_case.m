function mpc = debug_case(mpc)

% % delete the duplicated components
% bus_temp = rmpc.bus;
% bus_id_check = zero(max(bus_temp(:, 1)), 1);
% duplicate_bus_id = [];
% for i = 1:size(bus_temp, 1)
% 	id_bus = bus_temp(i, 1);
% 	if bus_id_check(id_bus) == 0
% 		bus_id_check(id_bus) = 1;
% 	else
% 		duplicate_bus_id(end+1) = i;
% 	end
% end
% rmpc.bus(duplicate_bus_id, :) = [];

% % delete the duplicated components
% gen_temp = rmpc.gen;
% gen_id = unique(gen_temp(:, 1));
% gen_flag = zeros(length(gen_id), 1);
% duplicate_gen_id = [];
% for i = 1:size(gen_temp, 1)

% 	temp_gen_id = gen_temp(i, 1);
% 	find_gen_id = find(gen_id == temp_gen_id, 1)
% 	if gen_flag(find_gen_id)  == 0
% 		gen_flag(find_gen_id) =1;
% 	else
% 		duplicate_gen_id(end+1) = i;
% 	end

% end

temp_bus_id = mpc.bus(:, 1);
[C,ia,ib]=unique(temp_bus_id,'rows','stable');
i=true(size(temp_bus_id,1),1);
i(ia)=false;
mpc.bus(i, :) = [];

temp_gen_id = mpc.gen(:, 1);
[C,ia,ib]=unique(temp_gen_id,'rows','stable');
i=true(size(temp_gen_id,1),1);
i(ia)=false;
mpc.gen(i, :) = [];
mpc.gencost(i, :) = [];

temp_branch_id = mpc.branch(:, 1:2);
[C,ia,ib]=unique(temp_branch_id,'rows','stable');
i=true(size(temp_branch_id,1),1);
i(ia)=false;
mpc.branch(i, :) = [];

% add a module to reIndex the bus number in BUS, BRANCH, GEN
% step 1: construct a LOOKUP table
numNodes = size(mpc.bus, 1); 
table_lookup = zeros(numNodes, 2);
for k = 1:numNodes
	table_lookup(k, 1) = k;
	table_lookup(k, 2) = mpc.bus(k, 1);
end
mpc.table_lookup = table_lookup;

% bus ID
mpc.bus(:, 1) = table_lookup(:, 1);
% Branches
numLines = size(mpc.branch, 1);
for k_c1 = 1:2
	for k_c2 = 1:numLines
		mpc.branch(k_c2, k_c1) = table_lookup(table_lookup(:, 2)==mpc.branch(k_c2, k_c1), 1);
	end
end
% Generator
numGen = size(mpc.gen, 1);
for kk = 1:numGen
	mpc.gen(kk, 1) = table_lookup(table_lookup(:, 2)==mpc.gen(kk, 1), 1);
end

% debug case (Dliu 20200922)
% gen output > 0
% bus input > 0
PG = 2; PD = 3; GS = 5;
mpc.bus(:, PD) = mpc.bus(:, PD) + mpc.bus(:, GS);
mpc.bus(:, GS) = 0;

mpc.gen(mpc.gen(:, PG)<0, PG) = 0;
mpc.bus(mpc.bus(:, PD)<0, PD) = 0;

end
