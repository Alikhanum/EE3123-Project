%% EE3123-2021

% info
% update network for single nodes
% used in the "extract_islands"

% Input
% mpc
% mpc_array: obtained by "subnetworks"

%%
function mpc = update_network_single_node(mpc, mpc_array)

%% initialize graph
[s, t] = GraphIncidence_no_br_status(mpc);
G = digraph(s,t);

%%
ZONE = 11;
GEN_STATUS = 8; BUS_TYPE = 2;
PG = 2; PD = 3; GS = 5;
PF = 14;

%%
num_subnet = size(mpc_array, 2);
id_PD_list = [];
id_PG_list = [];
% find single PD node & PG node
for i = 1:num_subnet
    subnetwork = mpc_array{i};
    id_PD_list = [id_PD_list; subnetwork.bus(:, 1)];
    id_PG_list = [id_PG_list; subnetwork.gen(:, 1)];
end

%% bus
id_single_PD_list = setdiff(mpc.bus(:, 1), id_PD_list);
mpc.bus(id_single_PD_list, PD) = 0;

%% gen
id_single_PG_list = setdiff(mpc.gen(:, 1), id_PG_list);
for j = 1:length(id_single_PG_list)
    id_signle_PG_row = find(mpc.gen(:, 1) == id_single_PG_list(j), 1);
    mpc.gen(id_signle_PG_row, PG) = 0;
end

%% branch
% for k = 1:length(id_single_PD_list)
%     bus_id = id_single_PD_list(k);
%     [out_ind, out_nid] = outedges(G, bus_id); % eid, temp{1}-vertex, indices=bus id
%     out_eid = [];
%     if isempty(out_ind) ~= 1
%         for i = 1: length(out_ind)
%             out_eid(i) = find(s==G.Edges.EndNodes(out_ind(i),1) & t==G.Edges.EndNodes(out_ind(i),2));
%         end
%     else
%         out_eid = [];
%     end
%     mpc.branch(out_eid, PF) = 0.001; % for plot, unable 0
% 
%     [in_ind, in_nid] = inedges(G, bus_id); % eid, temp{1}-vertex, indices=bus id
%     in_eid = [];
%     if isempty(in_ind) ~= 1
%         for ii = 1: length(in_ind)
%             in_eid(ii) = find(s==G.Edges.EndNodes(in_ind(ii),1) & t==G.Edges.EndNodes(in_ind(ii),2));
%         end
%     else
%         in_eid = [];
%     end
%     mpc.branch(in_eid, PF) = 0.001; % for plot, unable 0
%     mpc = mpc;
% end