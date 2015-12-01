function m_statistic, img, LEVELS = l
;+
; NAME:
;	M_STATISTIC
; PURPOSE:
;	To compute the multi-mode statistic (equation 2 of 
;	Freeman et al. (2013; arXiv:1306.1238)
; EXPLANATION:
;	Returns the multi-mode statistic given a segmentation-masked image and
;	a sequence of level set thresholds
;
; CALLING SEQUENCE:
;	out = m_statistic(img, LEVELS = l)
;
; INPUT PARAMETERS:
;	img - segmentation-masked image array
;
; OPTIONAL INPUT PARAMETERS:
;	LEVELS - a sequence of level set thresholds in the range [0,1]
;	         Default value: [0.5,0.98] by 0.02
;
; OUTPUT PARAMETERS:
;	A structure containing:
;	level - the level set threshold for which M is maximized
;	M - the multi-mode statistic
;       a1 - Area (in pixels) of largest clump
;       a2 - Area (in pixels) of 2nd largest clump
;
; EXAMPLE:
;	Compute the MID statistics for a given image
;
;	IDL> img = readfits('image.fits',h,/NOSCALE)
;	IDL> seg = gen_segmap(img)
;	IDL> img = img*seg
;	IDL> w = where(img lt 0)
;	IDL> if ( w ne -1 ) then img[w]=0
;	IDL> out = m_statistic(img)                  ****
;       IDL> M = out.M
;	IDL> out = i_statistic(img,SCALE=1)
;	IDL> I = out.I
;	IDL> D = d_statistic(img,out.x,out.y)
;
; FUNCTION CALLS:
;	REGION_GROW
;
; REVISION HISTORY:
;       v1.1 by Michael Peth
;           - Now returns the areas of the 1st and 2nd largest clumps
;           - Fixed equation for R = a2/a1 (removed *a2)
;	Written by P. Freeman (June 2013)
;-

if ( n_elements(l) eq 0 ) then begin
  levels = 0.5+0.02*findgen(25)
endif else begin
  levels = l
endelse
nlevels    = n_elements(levels)

dim        = size(img,/dimension)
npix       = n_elements(where(img ne 0))
norm_img   = img/max(img)
area_ratio = replicate(0.0,nlevels)
a1 = replicate(0.0,nlevels)
a2 = replicate(0.0,nlevels)

max_level  = 0

w          = where(norm_img ne 0)
snorm_img  = norm_img[w]
s          = sort(snorm_img)
snorm_img  = snorm_img[s]

clump_list = list() ;List contains information on clumps
;print, 'Npix = ', npix

for ii=0,nlevels-1 do begin
  thr = round(npix*levels[ii])-1
  w   = where(norm_img ge snorm_img[thr])
  if ( n_elements(w) gt 1 ) then begin ;0 -> 1
    r = region_grow(norm_img,l64indgen(dim[0]*dim[1]),$
                    /all_neighbors,threshold=[snorm_img[thr],1])
    if ( n_elements(r) gt 1 ) then begin
      clump = replicate(0,dim[0],dim[1])
      clump[r] = 1
      clump = label_region(clump,/all_neighbors)
      h = histogram(clump,min=1)
      if ( n_elements(h) gt 1 ) then begin
        s = sort(h)
        h = reverse(h[s])
	;print, levels[ii] 
	;print, 'Area ', h
	;print, 'threshold = ', thr
	;print, 'snormimg[thr] =', snorm_img[thr]
        area_ratio[ii] = (float(h[1])/float(h[0]))*float(h[1])
	;print, 'M =', area_ratio[ii]
        clump_list.add, clump
        a1[ii] = float(h[0]) ;Largest clump
        a2[ii] = float(h[1]) ;2nd largest clump
      endif
    endif
  endif
endfor

if ( max(area_ratio) gt 0 ) then begin
  w = where(area_ratio eq max(area_ratio))
  max_level = levels[w]
endif

M_stat = max(area_ratio,m_mxelem)
area1 = a1[m_mxelem]
area2 = a2[m_mxelem]

retval = {level:max_level,M:M_stat,a1:area1,a2:area2}


;plotimg = 1
;if plotimg eq 1 then begin       ; plot new xcenter, ycenter 
;       COMMON display_block
;       COMMON galaxy_block
;       rimg = galaxy_image

 ;      rimg2 = frebin(rimg, disp_dw, disp_dw)

       ; scale and set colors
       ;RGBim = nw_scale_rgb(RGBim,scales=scales)
       ;rimg2 = nw_arcsinh_fit(RGBim,nonlinearity=nonlinearity)
       ;rimg2 = nw_fit_to_box(RGBim,origin=origin)
       ;rimg2 = nw_float_to_byte(RGBim)

 ;      im = image(rimg2, dimensions=[400,400],image_dimensions=[400,400],margin=0)
 ;      cntr = contour(clump_list[w],n_levels=2,/overplot)
       
;       loadct, 0
       ;i = image(alog10(rimg2)) ;, 2
;       cgDisplay
;       cgLoadCT, 33, NColors=12
;       image = alog10(rimg2)
;       cgImage, image, Margin=1.0, /Scale, Top=11, /Save
;       cgContour, clump_list[w], NLEVELS=2, /OnImage, Color='white' 
;       loadct, 39

;       print, clump_list[w]
;       print, size(clump_list)
;       print, size(w)
;       contour, clump_list[w], levels=[2], xstyle=1,  $
;         ystyle=1,  thick=3, color=224, /noerase, /overplot


       ;im.Save, 'M_stamps_galid'+strtrim(id_string[i],1)+.eps', BORDER=0, /cmyk
       ;im.close
       
;endif

return, retval
end
