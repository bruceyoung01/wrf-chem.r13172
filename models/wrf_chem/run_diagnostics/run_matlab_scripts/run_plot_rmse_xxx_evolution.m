%
path='/scratch/summit/mizzi/DART_OBS_DIAG';
%
%exp         = '/real_FRAPPE_RETR_CONTROL/obs_diag_output.nc';
exp         = '/real_FRAPPE_RETR_MOP_CO/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_AIR_CO/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_CO_VLOC/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_AIR_CO/obs_diag_output.nc';
%
%exp         = '/real_FRAPPE_RETR_MOP_CO/2014071406/NOVLOC_HORZ_1p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_CO/2014071406/VLOC_HORZ_1p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_CO/2014071406/NOVLOC_NOHORZ_1p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_CO/2014071406/VLOC_NOHORZ_1p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_CO/2014071406/NOVLOC_NOHORZ_0p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_CO/2014071406/NOVLOC_NOHORZ_0p5_CUT_p05/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_CO/2014071406/VLOC_NOHORZ_0p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_CO/2014071406/NOVLOC_NOHORZ_0p5_CUT_p05/obs_diag_output.nc';
%exp         = '/real_FRAPPE_RETR_MOP_CO/2014071406/VLOC_NOHORZ_0p5_CUT_p05/obs_diag_output.nc';
%
%exp         = '/real_FRAPPE_CPSR_MOP_CO_NOVLOC/2014071406/NOVLOC_HORZ_1p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_CO_NOVLOC/2014071406/NOVLOC_NOHORZ_1p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_CO_VLOC/2014071406/VLOC_1p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_CO_VLOC/2014071406/VLOC_1p0/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_CO_VLOC/2014071406/VLOC_0p6/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_CO_VLOC/2014071406/VLOC_0p5/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_CO_VLOC/2014071406/VLOC_1p5_CUT_p05/obs_diag_output.nc';
%exp         = '/real_FRAPPE_CPSR_MOP_CO_VLOC/2014071406/VLOC_0p5_CUT_p05/obs_diag_output.nc';
%
fname=strcat(path,exp);
%
npar=1;
copystring    = {'totalspread'};
copystring    = {'spread'};
nvar=1;
%obsname      = {'AIRNOW_CO'};
%obsname      = {'AIRNOW_O3'};
%obsname      = {'IASI_CO_RETRIEVAL'};
obsname      = {'MOPITT_CO_RETRIEVAL'};
lbnd=0.;
ubnd=0.4;
%ubnd=0.3;
%ubnd=1.5;
%%ubnd=3.0;
%
for ipar=1:npar
for ivar=1:nvar
plot = plot_rmse_xxx_evolution(fname,copystring{ipar},'obsname',obsname{ivar});
%plot = plot_rmse_xxx_evolution(fname,copystring{ipar},'obsname',obsname{ivar},'range',[lbnd,ubnd]);
end
end
