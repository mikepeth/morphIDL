function gen_segmap, img, ETA = e, THRLEV = t
;+
; NAME:
;	GEN_SEGMAP
; PURPOSE:
;	To compute a segmentation map given a postage stamp image, using a
;	generalized variation on the Petrosian-ellipse approach of 
;	Lotz, Primack, and Madau (2004).  See section 4.3 of
;	Freeman et al. (2013; arXiv:1306.1238).
; EXPLANATION:
;	See section 4.3 of Freeman et al. for full explanation.
;       NOTE: the galaxy of interest is ** assumed to lie at the center of the
;       input postage stamp image! **
;
; CALLING SEQUENCE:
;	gen_segmap, img, ETA = e, THRLEV = t
;
; INPUT PARAMETERS:
;	img - galaxy postage stamp image
;
; OPTIONAL INPUT PARAMETERS:
;	ETA - the threshold ratio of mean brightness of pixels just added to the
;	      segmentation map to the mean brightness of all pixels in the map.
;	      When the observed ratio falls below ETA, the algorithm stops.
;	      Default value: 0.2 (following Lotz et al.)
;	THRLEV - threshold intensity quantile below which distinct clumps of 
;                pixels (clumps mapping to different local maxima) are not 
;	         merged, to avoid overblending.  Default value: 10 (ad hoc
;                value that works well with CANDELS data).  Larger values
;                encourage more blending of distinct clumps.
;
; OUTPUT PARAMETERS:
;	segmap - the segmentation map (values: 1 inside mask, 0 outside)
;
; EXAMPLE:
;	Compute the MID statistics for a given image
;
;	IDL> img = readfits('image.fits',h,/NOSCALE)
;	IDL> seg = gen_segmap(img)                   ****
;	IDL> img = img*seg
;	IDL> w = where(img lt 0)
;	IDL> if ( w ne -1 ) then img[w]=0
;	IDL> out = m_statistic(img)
;	IDL> M = out.M
;	IDL> out = i_statistic(img,SCALE=1)
;	IDL> I = out.I
;	IDL> D = d_statistic(img,out.x,out.y)
;
; PROCEDURE CALLS:
;	REGION_GROW
;
; REVISION HISTORY:
;	Written by P. Freeman (June 2013)
;-

if ( n_elements(e) eq 0 ) then begin
  eta = 0.2
endif else begin
  eta = e
endelse
if ( n_elements(t) eq 0 ) then begin
  thrlev = 10
endif else begin
  thrlev = t
endelse

dim  = size(img,/dimension)
xcen = floor(dim[0]/2)
ycen = floor(dim[1]/2)

s      = sort(img)
simg   = img[s]
npix   = n_elements(simg)
level  = 0.99-0.005*findgen(198)
nlevel = n_elements(level)

mu = -9

segmap = replicate(0,dim[0],dim[1])

for ii=0,nlevel-1 do begin
  r = region_grow(img,l64indgen(dim[0]*dim[1]),$
      /all_neighbors,threshold=[simg[floor(level[ii]*npix)],max(img)])
  clump = replicate(0,dim[0],dim[1])
  clump[r] = 1
  clump = label_region(clump,/all_neighbors)
  if ( clump[xcen,ycen] eq 0 ) then goto, skip
  w = where(clump eq clump[xcen,ycen])
  if ( mu gt 0 ) then begin
    dnw = n_elements(w)-nw
    if ( dnw lt 16 ) then goto, skip
    dmu = (total(img[w])-mu*nw)/dnw
    nw = n_elements(w)
      if ( dnw gt 1.1*dim[0]*dim[1]/200 ) and ( ii > thrlev-1 ) then begin
      r = region_grow(img,indgen(dim[0]*dim[1]),$
          /all_neighbors,threshold=[simg[floor(level[ii-1]*npix)],max(img)])
      clump = replicate(0,dim[0],dim[1])
      clump[r] = 1
      clump = label_region(clump,/all_neighbors)
      dmu = 0
    endif
    if ( dmu/(mu+dmu) lt eta ) then begin
      w = where(clump ne clump[xcen,ycen])
      clump[w] = 0
      segmap = clump/max(clump)
      istop = 0
      ; regularize (somewhat) the shape of the segmentation map
      while ( istop eq 0 ) do begin
        fill = replicate(0,dim[0],dim[1])
        for jj=1,dim[0]-2 do begin
          for kk=1,dim[1]-2 do begin
            if ( segmap[jj,kk] eq 0 ) then begin
              if ( total(segmap[(jj-1):(jj+1),(kk-1):(kk+1)]) gt 4 ) then begin
                fill[jj,kk] = 1
              endif
            endif
          endfor
        endfor
        if ( total(fill) eq 0 ) then istop=1
        segmap = segmap+fill
      endwhile
      return,segmap
    endif
  endif
  mu = mean(img[w])
  nw = n_elements(w)
  skip: continue
endfor

; the algorithm should never get to this point
w = where(clump ne clump[xcen,ycen])
clump[w] = 0
segmap = clump/max(clump)
return,segmap

end
