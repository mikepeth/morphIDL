
; read in 84x84 postage stamp for sample H-band image
img = readfits('ERS_2072_h.fits',h,/NOSCALE)

; compute the segmentation map based on algorith of Freeman et al. (section 4.3)
seg = gen_segmap(img,ETA=0.2,THRLEV=10)   ; default parameters set here

; or just read in a previously created map
; seg = readfits('ERS_2072_segmap.fits',h,/NOSCALE)
; w = where ( seg ne 2072 )
; seg[w] = 0
; seg = seg/max(seg)

; create segmentation-masked image
img = img*seg

; set pixels of negative intensity to zero
w = where(img lt 0)
if ( w ne -1 ) then img[w]=0

; compute the M statistic (assume default levels)
out = m_statistic(img)
M = out.M

; compute the I statistic, pre-smoothing the data with 1-pixel Gaussian kernel
out = i_statistic(img,SCALE=1)
I = out.I

; compute the D statistic, utilitizing output from I_STATISTIC
D = d_statistic(img,out.x,out.y)

print,M,I,D

end
