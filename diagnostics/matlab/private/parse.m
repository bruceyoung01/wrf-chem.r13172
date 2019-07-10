function x = parse(mystring)
%% parse  breaks a character string into a cell array of words
%
% Example:
% mystring = 'This has several words 1.234';
% x = parse(mystring)
% x =
%
%    'This'    'has'    'several'    'words'    '1.234'
%

%% DART software - Copyright 2004 - 2013 UCAR. This open source software is
% provided by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% DART $Id$

x{1} = [];
i    = 1;

while true

   [str, mystring] = strtok(mystring,' ');
   if isempty(str), break; end
   x{i} = str;
   i = i + 1;

end


% <next few lines under version control, do not edit>
% $URL$
% $Revision$
% $Date$

