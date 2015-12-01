FUNCTION A_ABS_MIN2, G, r_e, plot
   ftol = 1.0e-2
   p = [G.axc,  G.ayc, r_e] ; minimize xc,yc 
   print, p
   xi = [ [1.0, 0.0, 0.0], [0.0, 1.0, 0.0], $
          [0.0, 0.0, 0.0] ] 

   COMMON galaxy_block

   powell, p, xi, ftol, fmin, 'A_ABS2' 
   print, 'xcenter, ycenter = ', p 
   print, 'Asym Gal (C+B) = ', fmin 
   asym = fmin
   xc = p[0]
   yc = p[1]
   xx = [asym, xc, yc]

   if plot eq 1 then begin  ; display rotated subtracted image

       COMMON display_block

       I = galaxy_image
       I_180 = rot( I, 180, 1.0, xc, yc, /INTERP, /PIVOT, MISSING=0.0) 
       I_dif = I - I_180 
       amax = max(I_dif)    

       I_dif2 = frebin(I_dif, disp_dw, disp_dw)

      loadct, 0
      tv, bytscl(I_dif2, max=amax, min=-amax), 2

      loadct, 39     
      dist_circle, cir, galaxy_npix, xc, yc
      contour, cir, levels=[1.5*r_e], xstyle=1, xrange=[0, G.npix+1], $
         ystyle=1, yrange=[0, G.npix+1], thick=2, color=224, /noerase 

      xcs =[xc]
      ycs =[yc]

      oplot, xcs, ycs, psym=7, thick=3, color=224

      xyouts, 10, 10, "Asym", color=224

    
   endif

   return, xx   ; return A, best xcenter, best ycenter
 end 
