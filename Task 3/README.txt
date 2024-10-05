Task 3
DC power flow: The corresponding file is maintoBeCompleted.m.

An additional script is used - clear_net.m It shuts down the subnetwork with no generator.

To start, in file maintoBeCompleted.m uncomment the needed failure set. Code lines 61, 63, 65:
%failure_set = [93]; 
%failure_set = [93, 65]; 
%failure_set = [23, 93, 102];

Next, run main_toBeCompleted.m
No additional input is required


The output shows the history of cascade propagation and corresponding time step. In addition, list of all failed lines is displayed (it is just the list of lines)
The variable outlines stores the list of outlines
history_line - path of line cascade propagation (excluding initial failed lines)
history_time - time step when the corresponding line is overloaded
history_data - line failure and corresponding time step







Bonus: AC power flow: AC_maintoBeCompleted.m

Two additional scripts are used:
clear_net.m It shuts down the subnetwork with no generator.
Cal_AC_pf: include the power scaling and helps runpf() to merge

To start, in file AC_maintoBeCompleted.m uncomment the needed failure set. Code lines 61, 63, 65:
%failure_set = [93]; 
%failure_set = [93, 65]; 
%failure_set = [23, 93, 102];

Next, run main_toBeCompleted.m
No additional input is required
Same variables and output format are used









P.S. I am really grateful to Miss Li Meixuan who helped a lot with this task. She also pointed that function "update_network" must be located inside the for loop since we need to update the power flow result of each subnetwork into the final result variable “mpc”