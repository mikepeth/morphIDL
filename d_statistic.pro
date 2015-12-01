function d_statistic, img, xpeak, ypeak
;+
; NAME:
;	D_STATISTIC
; PURPOSE:
;	To compute the deviation statistic (equation 4 of 
;	Freeman et al. (2013; arXiv:1306.1238)
; EXPLANATION:
;	Returns the deviation statistic given a segmentation-masked image and
;       the pixel coordinates (x,y) returned by I_STATISTIC, where (x,y) is
;	the local maximum of the pixel clump of highest summed intensity
;       (denoted I_(1) in Freeman et al.)
;
; CALLING SEQUENCE:
;	d_statistic, img, xpeak, ypeak
;
; INPUT PARAMETERS:
;	img - segmentation-masked image array
;       xpeak - pixel coordinate x of local maximum of the pixel clump 
;	        of highest summed intensity, as returned by I_STATISTIC
;       ypeak - pixel coordinate y of local maximum of the pixel clump 
;	        of highest summed intensity, as returned by I_STATISTIC
;
; OUTPUT PARAMETERS:
;	A structure containing:
;	D - deviation statistic
;       nseg - Number of pixels in image unsing gen_segmap()
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
;	IDL> out = i_statistic(img,SCALE=1)
;	IDL> I = out.I
;	IDL> D = d_statistic(img,out.x,out.y)       ****
;
; FUNCTION CALLS:
;	None
;
; REVISION HISTORY:
;       v1.1 by Michael Peth
;           - Now returns the number of pixels in the segmap used for
;             normalization of D
;	Written by P. Freeman (June 2013)
;-

dim = size(img,/dimension)

tot  = 0
xcen = 0
ycen = 0

; Compute the weighted centroid of the galaxy, in pixel coordinates
for jj=0,dim[0]-1 do begin
  for kk=0,dim[1]-1 do begin
    if ( img[jj,kk] gt 0 ) then begin
      xcen = xcen+jj*img[jj,kk]
      ycen = ycen+kk*img[jj,kk]
      tot  = tot+img[jj,kk]
    endif
  endfor
endfor
xcen = xcen/tot
ycen = ycen/tot

; Compute the deviation of the weighted centroid from the first intensity peak
area = n_elements(where(img ne 0))
D = sqrt((xpeak-xcen)^2+(ypeak-ycen)^2)/sqrt(area/!PI)
Dprime = sqrt((xpeak-xcen)^2+(ypeak-ycen)^2)

retval = {D:D,nseg:area,xcen:xcen,ycen:ycen,Dprime:Dprime}
return,retval
end
