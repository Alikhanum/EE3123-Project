%% EE3123-2021

% info
% in case if power flow does not converge
% scale load and gen with a constant increment ratio, until converges

% Input
% mpc
% per: the increment scale ratio

% Output


%%
function mpc = scale_power_inj(mpc,per) %function load shedding

%input the case data mpc and the load shedding amount per such as 0.05

mpc.bus(:,3:4) = (1-per)* mpc.bus(:,3:4);
mpc.gen(:,2)=(1-per)*mpc.gen(:,2); %scale also the generation
