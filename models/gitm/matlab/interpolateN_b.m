function y_new = interpolateN_b(y_old,x_old,x_new)

% BIlinear N-Dimensional interpolation for data that is defined over
% rectangular grid (might work on weirder grids as well, but not tested).
%
% y_new = interpolateN_b(y_old,x_old,x_new)
%
% y_new is an array of inter-(extra-)polated values
% y_old is an array of data defined over a grid defined by x_old{k}
% x_old is a structure with coordinates of the grid
% x_new is a structure with coordinates of locations to be
% inter-(extra-)polated to
%
% REQUIREMENTS:
% - y_old must have N dimensions, NONE of which can have length 1 (please
%   use squeeze if you need to)
% -- DO NOT create 3D y_old via MESHGRID (or if you do, do
%    permute(y_old, [2 1 3]) before giving it to this routine).
% - both, x_old and x_new, must be a structure of Nx1 size.
% -- Each element in x_old and x_new structure must be a vector.
% --- Length of vectors comprising x_old must equal to the corresponding
%     sizes(dimensions) of y_old and they must be increasing arrays
%     (coordinate-arrays corresponding to edges (axis) of y_old = grid-locations
%     of where datapoints in y_old are taken
% --- The vectors comprising x_new must have equal length (what locations
%     do you want to interpolate y_old to?)
%
% NOTE: -it DOES extrapolate (and tells you how many points it had to
%        extrapolate - run or see the last 5 lines of this file.
%
% Algorithm details (optional to read): One interpolation issue is that (1,1,...,1) column is already in
% A (see code), so need to check that A is full rank
% So to do that just take the whole hyper-cube verticies (all 2^N points).
%
% USAGE:
% Example: N=2, y_old is 2x2
%
% interpolateN( [1 2; 2 3], {[1 3];[1 3]}, {2;2} )
%
% Example: N=3, y_old is 2x3x4
% y_old(:,:,1)=[1 2 3;
%               2 3 4];
% y_old(:,:,2)=[2 3 4;
%               3 4 5];
% y_old(:,:,3)=[3 4 5;
%               4 5 6];
% y_old(:,:,4)=[4 5 6;
%               5 6 7];
% x_old{1,1}=[1 2]; %row-dimension coordinates
% x_old{2,1}=[1 2 3]; %column-dimension coordinates
% x_old{3,1}=[1 2 3 4]; %depth-dimension coordinates
% x_new{1,1}=[1.1 1.2];
% x_new{2,1}=[1   2.3];
% x_new{3,1}=[1   3.4];
%
% Example from Wikipedia: N=2, http://en.wikipedia.org/wiki/Bilinear_interpolation
% yo=[0 1; 1 0.5];
% xo=[0 1];
% xn=0:0.05:1;
% [X,Y]=meshgrid(xn);
% yn=interpolateN_b(yo,{xo;xo},{X(:); Y(:)});
% YN=reshape(yn,length(xn),length(xn));
% surf(X,Y,YN, 'EdgeColor', 'none'); view(2); set(gca,'clim',[0 1]);
% colorbar

% DART $Id$

N=length(size(y_old)); %number of dims
ni=length(x_new{1}); %number of locations to be interpolated to

y_new=nan(1,ni);
fl=0;

for k=1:N
    if size(y_old,k)~=length(x_old{k}) %check if dimensions are right
        error('interpolateN:dimensions','y_old must have the same dimensions in the same order as x_old. Are you using meshgrid? Yes->read ''help interpolateN''')
    end
end

for i=1:ni
    disp(i)
    xi=nan(1,N); %coordinate of the upper furthest (1,1,1,...,1) vertix of the hyper-cube where the current interpolation location resides wrt the origin in y_old ((1,1,1,...) y_old_index)
    r=nan(1,N); %
    
    for k=1:N
        temp=find(x_old{k}(:)>x_new{k}(i));
        %         disp([isempty(temp) length(temp) length(x_old{k}) ])
        if isempty(temp) %if we are on the or to the right of the rightmost domain member
            xi(1,k)=length(x_old{k});
             r(1,k)=( x_old{k}(xi(1,k))-x_new{k}(i) )/( x_old{k}(xi(1,k))-x_old{k}(xi(1,k)-1) );
             k %[r(1,k) 1-r(1,k)]
            fl=fl+1;
            xodd(fl)=i;
        elseif length(temp)==length(x_old{k}) %if we are on the or to the left of the leftmost domain member
            xi(1,k)=2;
             r(1,k)=( x_old{k}(xi(1,k))-x_new{k}(i) )/( x_old{k}(xi(1,k))-x_old{k}(xi(1,k)-1) );
             k %[r(1,k) 1-r(1,k)]
            fl=fl+1;
            xodd(fl)=i;
        else
            xi(1,k)=temp(1);
             r(1,k)=( x_old{k}(xi(1,k))-x_new{k}(i) )/( x_old{k}(xi(1,k))-x_old{k}(xi(1,k)-1) );
        end
       
        
        
    end
    
    
    h=dec2bin(0:(2^N-1) )-48; %cube vertix coordinates in 0s and 1s
    in=ones(2^N,1)*xi-h;
    ri=(-2*h+1).*(ones(2^N,1)*r)+h; %r r r; r r (1-r); r (1-r) r; ...
    
    ri=flipud(ri); %because my cube is built backwards (111, 110, 101... 000), so r's need to be aligned with the right data points.
    
    R=prod(ri,2);
    Y=nan(2^N,1); %
    
    for j=1:2^N;
        ind='y_old(';
        for k=1:N
            ind=[ind 'in(' num2str(j) ',' num2str(k) '),'];
        end
        ind=[ind(1:(end-1)) ')']; %remove the last comma and close the paranthesis
        %             j
        %             ['[' ind(7:end-1) ']']
        %             size(y_old)
        %             eval(['[' ind(7:end-1) ']'])
        %             eval(ind)
        Y(j,1)=eval(ind);
    end
    
    y_new(i)= R'*Y; %evaluate the linear object at the desired location
    
end

if fl>0
    disp(['Extrapolation was used at ' num2str(fl) ' locations, out of ' num2str(ni) 'x' num2str(N) ' total, which is ' num2str(100*fl/(ni*N),'%.1f') ' percent.' ])
    disp(['In particular, the troublesome x_new indecies are ' num2str(xodd)])
    disp('(the above entries can be duplicated multiple times if the troublesome x_new location extends past domain on multiple dimensions)')
end
