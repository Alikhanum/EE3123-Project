%% EE3123-2021

% info
% Apply initial failures (trig assigned branches)

% Input:
% mpc: matpower case struct
%   (note: should maintain the initial data size (updated in each iteration
%   of the islands))
% failure_set: list, the branch index of line needs to cutoff

% Output:
% mpc: matpower test case format
% failure_set: the index of line needs to cutoff
% outlines: updated failed lines of the current time step


%%
function [mpc, outlines] = trig_lines(mpc, failure_set)

outlines = mpc.branch(:,11);

% set line not in service
mpc.branch(failure_set,11) = 0;
mpc.branch(failure_set,14:17) = 0;
outlines(failure_set) = 0;

return;