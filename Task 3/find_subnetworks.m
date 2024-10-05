%% EE3123-2021

% info
% note: subnetworks cannot identify single nodes

% input:
% mpc

% output:
% mpc_array: subnetworks, with >1 nodes
% mpc: updated mpc for single nodes

%%
function [mpc_array, mpc] = find_subnetworks(mpc)

mpc_array = subnetworks(mpc);

mpc = update_network_single_node(mpc, mpc_array);