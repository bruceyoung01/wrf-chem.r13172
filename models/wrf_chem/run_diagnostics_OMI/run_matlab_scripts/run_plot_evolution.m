fname         = '/glade/p/acd/mizzi/DART_OBS_DIAG/real_OMI_v3.6.1/obs_diag_output.nc';
%
varname      = {'OMI_NO2_COLUMN'};
%
% RMSE
%lbnd=3.5e15
%ubnd=7.5e15 
%copystring    = {'rmse'};
%
%Spread
%lbnd=0.2e15
%ubnd=1.65e15 
%copystring    = {'spread'};
%
% Total spread
%lbnd=1.35e15
%ubnd=1.75e15 
%copystring    = {'totalspread'};
%
% Bias
%lbnd=-0.5e15
%ubnd=0.55e15 
%copystring    = {'bias'};
%
% Observation
lbnd=0.2e15
ubnd=1.8e15 
copystring    = {'observation'};
%
% Ensemble Mean
%lbnd=0.2e15
%ubnd=1.8e15 
%copystring    = {'ens_mean'};
%
plot = plot_evolution(fname,copystring{1},'varname',varname{1},'range',[lbnd,ubnd]);
%plot = plot_evolution(fname,copystring{1},'varname',varname{1});

