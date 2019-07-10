function ln = interp1np(t,l,tn)
% Linear lon interpolation and EXTRAPOLATION (enabled by default) (uses interp1 calling convention)
% FOR PROGRADE ORBITS ONLY!! (like can't use this for subsolar point, since it moves in decreasing longitude direction as viewed in Earth-fixed frame!)

% DART $Id$

%test with 
% LonCD=interp1([1 4],[340 10],2)
% lp = interp1np([1 4],[340 10],2)
% lr = interp1nr([1 4],[340 10],2)

ex=1; %do you want extrapolation

if length(t)~=length(l)
    error('why is the length of first 2 inputs different?')
end

ln=nan(size(tn)); %prealloc

for i=1:length(tn)
%     disp(i)
    j=find(tn(i)<=t);
    
    if (isempty(j) && ex)
        j=length(t);
        
    elseif (length(j)==length(t) && ex)
        j=2;
    else
        j=j(1);
    end
    
    if ( l(j-1)>260 && l(j)<100 )
        ls=l(j)+360;
        ln(i)=mod( (ls - l(j-1)  )/(t(j)-t(j-1))*tn(i)+(-ls*t(j-1)+l(j-1)*t(j))/(t(j)-t(j-1)) , 360);
        
    else
        ln(i)=(l(j)-l(j-1))/(t(j)-t(j-1))*tn(i)+(-l(j)*t(j-1)+l(j-1)*t(j))/(t(j)-t(j-1));
    end
        
end
   
