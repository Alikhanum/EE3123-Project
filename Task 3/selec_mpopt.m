%%
% select the mpopt


%%
function mpopt = selec_mpopt(selection)

if selection == 'AC'
    mpopt = mpoption( 'out.all', 0, 'pf.nr.max_it', 50);
elseif selection == 'DC'
    mpopt = mpoption('OUT_ALL',0);
else
    error('Option does not exist!');
end
