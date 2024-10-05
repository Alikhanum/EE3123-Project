%% EE3123-2021

% info
% get the overload_line index

% Input:
% results: structure from OPF results
% alpha: line outage threshold (see setup_parameter); default: 0
%
% Output:
% overload_line: vector containing the overloaded line number(not including
% lines that have already been cut off)

%%
function [max_overload_line, overload_lines] = check_overload(mpc)

define_constants; % matpower function; for case struct indexes
BR_STATUS = 11;

% short term rating capacity
S_max = mpc.branch(:,6); 

% the apparent power flow over a link
S_branch = ((sqrt((mpc.branch(:, PF)).^2+(mpc.branch(:, QF)).^2)+sqrt((mpc.branch(:, PT)).^2+(mpc.branch(:, QT)).^2))/2);

S_diff = S_branch - S_max - 0.01; % 0.01 -> 1  inaccuracy tolerance
S_diff(find(mpc.branch(:,11)==0)) = 0;
overload_lines = find(S_diff>0);

if ~isempty(overload_lines)
    [m, n] = max(S_diff);
    max_overload_line = n;
else
    max_overload_line = [];
end

% dont't count burned lines twice
overload_lines(mpc.branch(overload_lines, BR_STATUS) == 0) = [];

end
