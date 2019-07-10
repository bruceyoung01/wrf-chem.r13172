fname         = '/glade/p/acd/mizzi/DART_OBS_DIAG/real_OMI_v3.6.1/obs_epoch_001.nc';
region        = [0 360 -90 90 -Inf Inf];
ObsTypeString = 'OMI_NO2_COLUMN';
CopyString    = 'NCEP BUFR observation';
QCString      = 'DART quality control';
maxgoodQC     = 4;
verbose       = 1;
twoup         = 2;
plot          = plot_obs_netcdf(fname, ObsTypeString, region, CopyString, ...
                      QCString, maxgoodQC, verbose, twoup);
