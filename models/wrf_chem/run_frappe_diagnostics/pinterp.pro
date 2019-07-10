function PINTERP, p, data, pint 

;INPUTS 
;  p(:)                 ! press array at desired lat, long
;  data(:)              ! data array at desired lat, long
;  pint                 ! interp press in Pa
;
; Vertical pressure interpolation at a given lat, long
; Note: the input p array is understood to have increasing 
;         values with increasing index i.e. p(mlev) > p(1)
;
      kmax = n_elements( p )

      if( pint gt p[kmax-1] ) then $
;	 PINTERP = data[kmax-1] $
        pinterp = -999. $
      else if( pint lt p[0] ) then $
;	 PINTERP = data[0] $
        pinterp = -999. $
      else if( pint eq p[kmax-1] ) then $
        pinterp = data[kmax-1] $
      else begin
         k = kmax-1
         REPEAT k=k-1 UNTIL ( pint ge p[k] and pint lt p[k+1] )
	 kp1 = k + 1
	 delp = float(pint - p[k]) / (p[kp1] - p[k])
         PINTERP = data[k] + delp * (data[kp1] - data[k])
      endelse

      return,pinterp
      end  
