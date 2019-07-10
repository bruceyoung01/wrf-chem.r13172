%
path='/scratch/summit/mizzi/DART_OBS_DIAG';
exp         = '/real_FRAPPE_CONTROL/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_CO/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_CO/obs_diag_output.nc';
%
fname=strcat(path,exp);
%
%copystring    = 'ens_mean';
%copystring    = 'observation';
%copystring    = 'bias';
copystring    = 'rmse';
%obsnamevar     = 'AIRNOW_CO';
%obsnamevar     = 'AIRNOW_O3';
obsnamevar     = 'MOPITT_CO_RETRIEVAL';
%obsnamevar     = 'IASI_CO_RETRIEVAL';
%
  plot = plot_profile(fname,copystring,'obsname',obsnamevar);

