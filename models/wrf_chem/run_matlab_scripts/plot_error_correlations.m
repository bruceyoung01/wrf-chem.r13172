function main
   clear all
%
% set constants
   nx=179;
   ny=139;
   nz=36;
   nmem=3;
   pi=4.*atan(1.0);
   sprd_anthro=.30;
   corr_half_width=800.;
%
% read lat and lon
   filein='/scratch/summit/mizzi/real_FRAPPE_RETR_AIR_CO/2014071406/wrfchem_chem_emiss/wrfinput_d01';
   lon=ncread(filein,'XLONG');
   lat=ncread(filein,'XLAT');
%
% get grid length
grid_len=get_dist(lat(floor(nx/2),floor(ny/2)),lat(floor(nx/2)+1,floor(ny/2)),lon(floor(nx/2),floor(ny/2)),lon(floor(nx/2)+1,floor(ny/2)));
%
% get number of points to be correlated
   ngrid_corr=ceil(corr_half_width/grid_len)+1;
%
% generate random perturbations N(0,1)
   for imem=1:nmem
      for i=1:nx
         for j=1:ny
            ran1=rand;
            while ran1==0.
               ran1=rand;           
            end
            ran2=rand;
            while ran2==0.
               ran2=rand;           
            end
            pert(i,j)=sqrt(-2.*log(ran1))*cos(2.*pi*ran2);
         end
      end
%
% add correlations
      for i=1:nx
         for j=1:ny
            wgt_sum=0.;
            prt_sum=0.;
            for ii=max(1,i-ngrid_corr):min(nx,i+ngrid_corr)         
               for jj=max(1,j-ngrid_corr):min(ny,j+ngrid_corr)         
 	          dist=get_dist(lat(ii,jj),lat(i,j),lon(ii,jj),lon(i,j));
                  if (dist<=corr_half_width)
                     wgt=1./exp(dist*dist/corr_half_width/corr_half_width);
		     wgt_sum=wgt_sum+wgt;
		     prt_sum=prt_sum+wgt*pert(ii,jj);
                  end
               end
            end
	    fac(i,j,imem)=prt_sum/wgt_sum;
         end
      end
   end
%
% calculate emissions factor
   for i=1:nx
      for j=1:ny
         mems(:)=fac(i,j,:);
         zmean(i,j)=mean(mems);
         zstd(i,j)=std(mems);
	 for imem=1:nmem
            em_fac(i,j,imem)=(fac(i,j,imem)-zmean(i,j))/zstd(i,j)*sprd_anthro;
         end
      end
   end
%
% plot map of fac
   red     =   ([ 228, 161,   0,   0,   0, 144, 255, 255, 255, 255, 255, 255]);
   green   =   ([ 239, 179, 104, 204, 255, 255, 255, 191, 102,   0,   0, 103]);
   blue    =   ([ 255, 223, 255, 255,   0, 130,   0,   0,   0,   0, 255, 255]);
   desired_colors = ([red',green',blue'] ) / 256;
%
% now decide on the colormap
   cmap=desired_colors;
   load usahi;
   [lats,lons]=extractm(stateline);
   coastlines2(:,2)=lons;
   coastlines2(:,1)=lats;
%

% in global models, sometimes i need to flip longitudes
   flip=0;
   if (flip==1)
      coastlines=coastlines2;
      for i=1:size(coastlines,1)
         if (coastlines2(i,2)<=0)
            coastlines(i,2)=coastlines2(i,2)+180;
         else
            coastlines(i,2)=coastlines2(i,2)-180;
         end
      end
   else
      coastlines=coastlines2;    
   end
   row_c=find(coastlines(:,2)<-178.5 & coastlines(:,2)>=-180 );
   coastlines(row_c,2)=NaN;

   coasts = load('coast.mat');
   coastlines0 = [coasts.lat,coasts.long];
   clear coasts

   flip=0;
   if (flip==1)
      coastlin=coastlines0;
      for i=1:size(coastlin,1)
         if (coastlines0(i,2)<=0)
            coastlin(i,2)=coastlines0(i,2)+180;
         else
            coastlin(i,2)=coastlines0(i,2)-180;
         end
      end
   else
      coastlin=coastlines0;    
   end
   row_c=find(coastlin(:,2)<-178.5 & coastlin(:,2)>=-180 );
   coastlin(row_c,2)=NaN;
%
%------------------------------------------
% now plot
%------------------------------------------
   for imem=1:1;
      ifig=1;
      h(ifig)=figure;
      clf(ifig);
%
% position the figure
      set(h(ifig),'Units','pixels','Position',[700 450 620 350]); 
%      contourf(lon,lat,em_fac(:,:,imem),12,'LineStyle','none');
      contourf(lon,lat,zmean,12,'LineStyle','none');
%      contourf(lon,lat,zstd,12,'LineStyle','none');
%      caxis([-0.04 0.04]);
      hold on;
      h(ifig)=plot(coastlines(:,2), coastlines(:,1),'k.-','Linewidth',1.0);
      set(h,'MarkerSize',0.1);
      h(ifig)=plot(coastlin(:,2), coastlin(:,1),'k.-','Linewidth',1.0);
      set(h,'MarkerSize',0.1);
%
% aesthetics
      ylim([31 46]);
      xlim([-124 -97]);
      title('TEST PLOT','Fontsize',18,'FontWeight','bold');
      set(gca,'Xtick', [-120 -115 -110 -105 -100],'FontWeight','bold','TickLength',[0.025 0.025]);
      set(gca,'XtickLabel',['120W';'115W';'110W';'105W';'100W'],'Fontsize',14,'FontWeight','bold');
      set(gca,'Ytick',[32 36 40 44],'FontWeight','bold','TickLength',[0.025 0.025]);
      set(gca,'YtickLabel',['32N'; '36N'; '40N'; '44N'],'Fontsize',14,'FontWeight','bold');
      set(gca,'Fontsize',14);
      ax=gca;
%
% colorbar
      hh=colorbar('eastoutside');
      axx=gca;
      set(hh,'Fontsize',16,'FontWeight','bold');
      set(get(hh,'XLabel'),'String','ppbv','Fontsize',14,'FontWeight','bold');
      ylabel('Latitude','Fontsize',18,'FontWeight','bold');
      xlabel('Longitude','Fontsize',18,'FontWeight','bold');
      box on;
      set(gca,'LineWidth',2);
      colormap(cmap);
      status=1;
      fig=h(ifig);
      print(gcf,'-dpsc','-append','test_plot');
%      saveas(figure(ifig),'test_plot','psc2')
   end
end
%
function [dist]=get_dist(lat1,lat2,lon1,lon2)  
   pi=4.*atan(1.0);
   ang2rad=pi/180.;
   r_earth=6371.393;
   coef_a=sin((lat2-lat1)/2.*ang2rad) * sin((lat2-lat1)/2.*ang2rad) + ...
   cos(lat1*ang2rad)*cos(lat2*ang2rad) * sin((lon2-lon1)/2.*ang2rad) * ...
   sin((lon2-lon1)/2.*ang2rad);
   coef_c=2.*atan2(sqrt(coef_a),sqrt(1.-coef_a));
   dist=coef_c*r_earth;  
end
