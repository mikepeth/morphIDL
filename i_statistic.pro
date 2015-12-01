function i_statistic, img, SCALE = s
;+
; NAME:
;	I_STATISTIC
; PURPOSE:
;	To compute the intensity statistic (equation 3 of 
;	Freeman et al. (2013; arXiv:1306.1238)
; EXPLANATION:
;	Returns the intensity statistic given a segmentation-masked image, and
;       returns the pixel coordinates (x,y) of the image local maximum 
;	associated with the largest summed intensity
;
; CALLING SEQUENCE:
;	i_statistic, img, SCALE = s
;
; INPUT PARAMETERS:
;	img - segmentation-masked image array
;
; OPTIONAL INPUT PARAMETERS:
;	SCALE - sigma of two-dimensional, symmetric Gaussian used to 
;	        pre-smooth noisy data to reduce bias in the computation of I
;               (unit: pixels)
;
; OUTPUT PARAMETERS:
;	A structure containing:
;	I - intensity statistic
;       x - pixel coordinate x of local maximum of the pixel clump 
;	    of highest summed intensity, for use in D_STATISTIC
;       y - pixel coordinate y of local maximum of the pixel clump 
;	    of highest summed intensity, for use in D_STATISTIC
;
; EXAMPLE:
;	Compute the MID statistics for a given image
;
;	IDL> img = readfits('image.fits',h,/NOSCALE)
;	IDL> seg = gen_segmap(img)
;	IDL> img = img*seg
;	IDL> w = where(img lt 0)
;	IDL> if ( w ne -1 ) then img[w]=0
;	IDL> out = m_statistic(img)
;	IDL> M = out.M
;	IDL> out = i_statistic(img,SCALE=1)          ****
;	IDL> I = out.I
;	IDL> D = d_statistic(img,out.x,out.y)
;
; FUNCTION CALLS:
;	I_SMOOTH - optional pre-smoothing of input image
;       I_CLUMP  - watershed-like algorithm for associated pixels with
;                  local maxima via steepest gradient ascent
;
; REVISION HISTORY:
;	Written by P. Freeman (June 2013)
;-
if ( n_elements(s) eq 0 ) then begin
  scale = 0
endif else begin
  scale = s
endelse

dim = size(img,/dimension)

cimg = img
if ( scale gt 0 ) then cimg = i_smooth(img,scale)

out = i_clump(cimg)

w = where(out.xpeak ne -9)
if ( n_elements(w) eq 1 ) then begin
  int_ratio = 0.0
  xpeak     = out.xpeak[0]
  ypeak     = out.ypeak[0]
endif else begin
  int_clump = replicate(0.0,n_elements(w))
  for jj=0,dim[0]-1 do begin
    for kk=0,dim[1]-1 do begin
      if ( out.clump[jj,kk] gt 0 ) then begin
        int_clump[out.clump[jj,kk]-1] = int_clump[out.clump[jj,kk]-1]+img[jj,kk]
      endif
    endfor
  endfor
  mx        = max(int_clump,mxelem)
  xpeak     = out.xpeak[mxelem]
  ypeak     = out.ypeak[mxelem]
  s         = sort(int_clump)
  int_clump = reverse(int_clump[s])
  int_ratio = int_clump[1]/int_clump[0]
endelse

retval = {I:int_ratio,x:xpeak,y:ypeak}
return,retval
end
