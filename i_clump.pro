function i_clump, img
;+
; NAME:
;	I_CLUMP
; PURPOSE:
;	To group pixels according to their local maxima, via steepest gradient
;       ascent.  Similar to the IDL routine WATERSHED.
; EXPLANATION:
;	For each image pixel, find the maximum amplitude in the eight 
;	surrounding pixels; if this amplitude is greater than the current
;	amplitude, move to pixel of maximum amplitude and repeat until the
;       local maximum is reached.
;
; CALLING FUNCTION:
;	I_STATISTIC
;
; CALLING SEQUENCE:
;	i_clump, img
;
; INPUT PARAMETERS:
;	img - segmentation-masked image array
;
; OUTPUT PARAMETERS:
;	A structure containing:
;	clump - an image array showing pixel clumps with distinct local maxima
;	xpeak - the x-coordinates of the local maxima
;	ypeak - the y-coordinates of the local maxima
;
; EXAMPLE:
;	See usage within I_STATISTIC
;
; FUNCTION CALLS:
;	None
;
; REVISION HISTORY:
;	Written by P. Freeman (June 2013)
;-

dim   = size(img,/dimension)
clump = replicate(-1,dim[0],dim[1])
xpeak = replicate(-9,100)
ypeak = replicate(-9,100)

for jj=0,dim[0]-1 do begin
  for kk=0,dim[1]-1 do begin
    if ( img[jj,kk] eq 0 ) then goto, skip
    jjcl = jj
    kkcl = kk
    istop = 0
    while ( istop eq 0 ) do begin
      jjmax = jjcl
      kkmax = kkcl
      imgmax = img[jjcl,kkcl]
      for mm=-1,1 do begin
        if ( jjcl+mm ge 0 ) and ( jjcl+mm lt dim[0] ) then begin
          for nn=-1,1 do begin
            if ( kkcl+nn ge 0 ) and ( kkcl+nn lt dim[1] ) then begin
              if ( img[jjcl+mm,kkcl+nn] gt imgmax ) then begin
                imgmax = img[jjcl+mm,kkcl+nn]
                jjmax = jjcl+mm
                kkmax = kkcl+nn
              endif
            endif
          endfor
        endif
      endfor
      if ( jjmax eq jjcl ) and ( kkmax eq kkcl ) then begin
        ifound = 0
        mm = 0
        while ( ifound eq 0 ) and ( xpeak[mm] ne -9 ) and ( mm lt 99 ) do begin ;mm lt 100 -> mm lt 99
          if ( xpeak[mm] eq jjmax ) and ( ypeak[mm] eq kkmax ) then begin
            ifound = 1
          endif else begin
            mm = mm+1
          endelse
        endwhile
        if ( ifound eq 0 ) then begin
          xpeak[mm] = jjmax
          ypeak[mm] = kkmax
        endif
        clump[jj,kk] = mm
        istop = 1
      endif else begin
        jjcl = jjmax
        kkcl = kkmax
      endelse
    endwhile
    skip: continue
  endfor
endfor
clump=clump+1

retval = {clump:clump,xpeak:xpeak,ypeak:ypeak}
return, retval
end
