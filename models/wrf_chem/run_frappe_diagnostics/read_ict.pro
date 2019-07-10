FUNCTION READ_ict,file

;close, /all
dummy = ''
nheader=0
index=0
 
nfiles = n_elements(file)

for ifile=0,nfiles-1 do begin
;    print, file[ifile]
    OPENR,1,file[ifile]
    readf,1,nheader, index
    headerinfo = strarr(nheader-1)
    for i=0,nheader-2 do begin
        readf,1,dummy
        headerinfo(i) = dummy
    endfor

    nvar = fix(headerinfo(8))+1
    varnames = strarr(nvar)
    varnames(0)='TIME'
    varnames(1:nvar-1) = headerinfo(11:11+nvar-2)
    
    tmp = strcompress(strsplit(headerinfo(9),' '),/remove_all)
    i=where(tmp ne '')
    if n_elements(i) le 1 then  begin
        tmp = strcompress(strsplit(headerinfo(9),','),/remove_all)
        i=where(tmp ne '')
    endif
    scales = float(tmp(i))
    if n_elements(scales) ne nvar-1 then print,'Error in Scalefactors'

; start reading data
    if ifile eq 0 then begin
        nmax = 5000000L
        data = fltarr(nvar, nmax)
        flightnr = fltarr(nmax)
        count=0L
    endif
    line= fltarr(nvar)-999
    dummy=''
    fileend = 0
;    WHILE NOT EOF(1) AND fileend EQ 0 DO BEGIN
;        readf,1,dummy
;        if strcompress(dummy,/remove_all) eq '' then fileend=1
;        tmp = strsplit(dummy,',')
;        itmp = where(tmp ne '', ntmp)
;        if ntmp eq nvar then begin
;            data(*,count) = float(tmp(itmp))
;            flightnr[count] = ifile
;            count=count+1L
;        endif
;    ENDWHILE



    CLOSE,1
;- Read the data (Rajesh)
  nlines = file_lines(file[ifile])
  tmp_data = strarr(nlines)
  
  openr, 1, file[ifile]
   readf, 1, tmp_data
  close, 1
  for nl = nheader, nlines-1 do begin
   tmp = strsplit(tmp_data[nl], ',',/extract, count = ntmp)

   if ntmp eq nvar then begin
    data[*,count] = tmp[*]
    flightnr[count] = ifile
    count=count+1L
   endif
  endfor

endfor


data = EXTRAC(data,0,0,nvar,count)
flightnr = EXTRAC(flightnr,0,count)
res = {header:headerinfo, nvar:nvar, varnames:varnames, data:data, flightnr:flightnr}
RETURN, res

end
