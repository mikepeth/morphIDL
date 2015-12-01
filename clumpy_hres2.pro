FUNCTION clumpy_hres2, G,  plot

 COMMON galaxy_block
 rimg = galaxy_image

 r_e = pet_rad_cir_hres2(0.2, G)
 
 width = (1.5*r_e)/ 6.0  ; smoothing length
 

 if (width gt G.psf/G.scale) then begin

     size=1000
     r_e = size/float(G.npix)* r_e
     width = size/float(G.npix)* width
     rimg2 = frebin(rimg, size, size) 
     xc = size/float(G.npix)* G.axc
     yc = size/float(G.npix)* G.ayc

                                ; smooth image
     srimg = FILTER_IMAGE(rimg2, smooth=width, /ALL_PIXELS)
     c1 = rimg2 - srimg

                                ; set negative pixels to zero
     neg = where(c1 lt 0.0)
     c1(neg) = 0.0
 
                                ; set center region to zero
     center = (1.5*r_e)/20.0    ; central region to be ignored
     dist_circle, cir, size, xc, yc ; region to measure S
     ap1 = where(cir lt center)
     if (N_ELEMENTS(ap1) gt 1) then c1(ap1) = 0.0
 
                                ; measure total within 1.5 rpet
     ap2 = where(cir lt 1.5*r_e)
     s1 = avg(c1(ap2))
     r1 = avg(rimg(ap2))
 
                                ; sky correction
     S = G.skybox * size/float(G.npix) 
     b1 = c1[S[0]:S[1], S[2]:S[3]]
     bkg = avg(b1)

     smoothness = 10.0* (s1 - bkg)/r1

 endif else begin
     smoothness=-99.0
     rimg2 = rimg
     srimg = FILTER_IMAGE(rimg2, smooth=width, /ALL_PIXELS)
 endelse


 if plot eq 1 then begin        ; plot smoothed, subtracted image

      COMMON display_block

      simg2 = rimg2 - srimg
      smin = min(simg2)
      simg3 = frebin(simg2, disp_dw, disp_dw)

      loadct, 0
      tv, bytscl(simg3, max=-smin, min=smin), 2

      loadct, 39
     
      dist_circle, cir, G.npix, G.axc, G.ayc
      contour, cir, levels=[1.5*r_e/20, 1.5*r_e], xstyle=1, xrange=[0, G.npix+1], $
         ystyle=1, yrange=[0, G.npix+1], thick=3, color=224, /noerase 

      ;xcs =[xc]
      ;ycs =[yc]
      
      xyouts, 5, 5, 'Smoothness"
      wait, 2

      print, "S = ", smoothness

      ;oplot, xcs, ycs, psym=7, thick=3, color=224
     

  endif

 return, smoothness

end

