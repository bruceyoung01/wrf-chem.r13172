%% ensemble

%% DART software - Copyright 2004 - 2013 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% DART $Id$

fname = 'Prior_Diag.nc';
tlon = getnc(fname, 'TmpI');
num_tlon = size(tlon, 1);
tlat = getnc(fname, 'TmpJ');
num_tlat = size(tlat, 1);
vlon = getnc(fname, 'VelI');
num_vlon = size(vlon, 1);
vlat = getnc(fname, 'VelJ');
num_vlat = size(vlat, 1);
level = getnc(fname, 'level');
num_level = size(level, 1);

state_vec = getnc(fname, 'state');

% Get a time level from the user
time_ind = input('Input time level');

% Get an ensemble member from user
ens_ind = input('Input an ensemble member to plot');

single_state = state_vec(time_ind, ens_ind, :);

% Select field to plot (ps, t, u, v)
field_num = input('Input field type, 1=ps, 2=t, 3=u, or 4=v')

% Get level for free atmosphere fields
if field_num > 1
   field_level = input('Input level');
else
   field_level = 1;
end

% Extract ps or T fields
if field_num < 3
   offset = field_num + field_level - 1;

   field_vec = single_state(offset : num_level + 1 : (num_level + 1) * (num_tlon * num_tlat));

   field = reshape(field_vec, [num_tlat num_tlon]);

% Otherwise it's on v-grid
else

   base = (num_level + 1) * (num_tlon * num_tlat)
   offset = (field_level - 1) * 2 + (field_num - 2);

   field_vec = single_state(base + offset : 2 * num_level : base + 2 * num_level * num_vlat * num_vlon)
   field = reshape(field_vec, [num_vlat, num_vlon])

end


[C, h] = contourf(field);
clabel(C, h);

% Loop for another try
ensemble;

% <next few lines under version control, do not edit>
% $URL$
% $Revision$
% $Date$

