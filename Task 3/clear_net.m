function results = clear_net(results)

define_constants; %define constants for matpower 

results.bus(:, PD) = 0;
results.bus(:, QD) = 0;
results.bus(:, GS) = 0;
results.gen(:, PG) = 0;
results.gen(:, QG) = 0;
results.branch(:, PF) = 0;
results.branch(:, QF) = 0;
results.branch(:, PT) = 0;
results.branch(:, QT) = 0;