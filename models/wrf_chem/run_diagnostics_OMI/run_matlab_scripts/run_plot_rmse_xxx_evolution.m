fname         = '/glade/p/acd/mizzi/DART_OBS_DIAG/real_OMI_v3.6.1/obs_diag_output.nc';

%
obsname      = {'OMI_NO2_COLUMN'};
%
% Total Spread
lbnd=0.0e15
ubnd=2.e15
copystring    = {'totalspread'};
%
% Spread
lbnd=0.0e15
ubnd=0.75e15
copystring    = {'spread'};
%
plot = plot_rmse_xxx_evolution(fname,copystring{1},'obsname', obsname{1},'range', [lbnd, ubnd]);



