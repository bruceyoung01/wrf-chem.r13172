
fname         = '/glade2/scratch2/mizzi/DART_OBS_DIAG/real_FRAPPE_RETR_AIR_CO/dart_filter_iasi_co_rawr/obs_epoch_001.nc'
fname         = '/glade2/scratch2/mizzi/DART_OBS_DIAG/real_FRAPPE_RETR_AIR_CO/dart_filter_iasi_co_log/obs_epoch_001.nc'
fname         = '/glade2/scratch2/mizzi/DART_OBS_DIAG/real_FRAPPE_RETR_AIR_CO/dart_filter/obs_epoch_001.nc'
region        = [227 267 26 49 -Inf Inf];
%ObsTypeString = 'MOPITT_CO_RETRIEVAL';
ObsTypeString = 'IASI_CO_RETRIEVAL';
%ObsTypeString = 'IASI_O3_RETRIEVAL';
CopyString    = 'NCEP BUFR observation';
QCString      = 'DART quality control';
maxgoodQC     = 2;
verbose       = 1;
twoup         = 0;
plot          = plot_obs_netcdf(fname, ObsTypeString, region, CopyString, ...
                      QCString, maxgoodQC, verbose, twoup);
