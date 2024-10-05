%% EE3123-2021

% Info
% function make directional graph from mpc

% Input
% mpc

% Output
% vector of s and t

%%
function [s, t] = GraphIncidence_no_br_status(mpc)

s = mpc.branch(:,1);
t = mpc.branch(:,2);

end