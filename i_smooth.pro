function i_smooth, img, scale
;+
; NAME:
;       I_SMOOTH
; PURPOSE:
;       To smooth an input image using a two-dimensional, symmetric Gaussian
;       with sigma = scale
; EXPLANATION:
;	Smoothing an image prior to computing the I statistic is advised, as
;       noise can introduce spurious local maxima (of small prominence)
;       into a galaxy image.  The smoothing scale should be small (~1 pixel)
;       so as to smooth out noise, but *not* real structures!
;
;       NOTE: convolve() could be used for this purpose, but it introduces 
;       numerical noise at places where the original image was zero, which
;       messes up the computation in I_CLUMP...and there's issues with boundary
;       effects at the edges of the segmentation map...for small postage stamps
;	(~100 x ~100 pixels) and small scales (~1 pixel), this algorithm runs
;	quickly enough
;
; CALLING FUNCTION:
;       I_STATISTIC
;
; CALLING SEQUENCE:
;       i_smooth, img, scale
;
; INPUT PARAMETERS:
;       img - segmentation-masked image array
;       scale - sigma of two-dimensional, symmetric Gaussian used to smooth
;               the data in img
;
; OUTPUT PARAMETERS:
;	smooth - the smoothed analogue to img
;
; EXAMPLE:
;       See usage within I_STATISTIC
;
; FUNCTION CALLS:
;       None
;
; REVISION HISTORY:
;       Written by P. Freeman (June 2013)
;-

dim = size(img,/dimension)

boxsize = ceil(3.0*float(scale))
if ( boxsize MOD 2 eq 0 ) then boxsize = boxsize+1
lo = floor(float(boxsize)/2.0)
hi = ceil(float(boxsize)/2.0)

smooth  = replicate(0.0,dim[0],dim[1])
for jj=lo,dim[0]-hi do begin
  for kk=lo,dim[1]-hi do begin
    if ( img[jj,kk] ne 0 ) then begin
      tw = 0
      for mm=-lo,lo do begin
        for nn=-lo,lo do begin
          if ( img[jj+mm,kk+nn] ne 0 ) then begin
            dist2 = mm^2+nn^2
            w = exp(-float(dist2)/2.0/float(scale^2))/(2*!PI)/float(scale^2)
            smooth[jj,kk] = smooth[jj,kk] + img[jj+mm,kk+nn]*w
            tw = tw+w
          endif
        endfor
      endfor
      smooth[jj,kk] = smooth[jj,kk]/tw
    endif
  endfor
endfor
return,smooth
end
