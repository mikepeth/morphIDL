FUNCTION MOMENT_20_2, G, rpet, plot
  ; this function finds second order moment of galaxy
  ; for brightest 20% of the pixels

  COMMON galaxy_block
  rimg = galaxy_image

  xcenter = G.mxc
  ycenter = G.myc

  n = long(N_ELEMENTS(rimg))
  radius = fltarr(n)

  mom_t = 0.0

  ii= dindgen(n)
  ix = float(ii mod G.npix) + 0.5
  iy = float(ii)/ float(G.npix) + 0.5
  radius = sqrt( (ix - xcenter)^2 + (iy - ycenter)^2)

  ; get galaxy pixels
  map = segmap2(G.mxc, G.myc, rpet)
  gal = where(map gt 0.0, n2)  

   if (map[xcenter, ycenter] eq 10.0) then begin 
         rimg2 = rimg(gal) 
         rad2 = radius(gal)   
         moment = rimg2* rad2*rad2
          mom_t = total(moment) 
   endif else mom_t = 1e20

 
   ; reverse rank order pixels
   srimg = rimg2(reverse(sort(rimg2)))
   srad = rad2(reverse(sort(rimg2)))

   ; sum moment for brightest 20% of flux
   mom2 = 0.0
   sum2 = 0.0
   for i=0L, n2-1 DO BEGIN
       sum2 = sum2 + srimg[i]
       mom2 = mom2 +  (srimg[i])*(srad[i])^2

      if (sum2/total(rimg2) gt 0.20) then begin
          maxflux = srimg[i]
          i = n2
      endif
  endfor

  if plot eq 1 then begin       ; plot new xcenter, ycenter 

       COMMON display_block

       rimg2 = frebin(rimg, disp_dw, disp_dw)
 
       loadct, 0
       tv, bytscl(alog10(rimg2), alog10(disp_immin), alog10(disp_immax)), 2

       loadct, 39

       contour, map, levels=[10], xstyle=1, xrange=[0, G.npix+1], $
         ystyle=1, yrange=[0, G.npix+1], thick=3, color=224, /noerase

       contour, rimg, levels=[maxflux], xstyle=1, xrange=[0, G.npix+1], $
         ystyle=1, yrange=[0, G.npix+1], thick=1, c_color=[150], /noerase
       
       xcs=[G.mxc]
       ycs=[G.myc]
       oplot, xcs, ycs, psym=7, thick=2, color=224

      xyouts, 5, 5, "M_20"
endif


print, 'M20 is ', alog10(mom2/mom_t)
return, mom2/mom_t
end
