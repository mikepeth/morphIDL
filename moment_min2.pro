FUNCTION MOMENT_MIN2, G, r_e, plot
   ftol = 1.0e-1 
   p = [G.mxc,  G.myc, r_e] 
   xi = [ [1.0, 0.0, 0.0], [0.0, 1.0, 0.0], $
          [0.0, 0.0, 0.0] ] 

   COMMON galaxy_block

   powell, p, xi, ftol, fmin, 'MOMENT2', /DOUBLE
   print, 'xcenter, ycenter = ', p 
   print, 'MOMENT_T = ', fmin 

   if plot eq 1 then begin

       COMMON display_block

       I = galaxy_image
        
       I2 = frebin(I, disp_dw, disp_dw)
       loadct, 0
       tv, bytscl(alog10(I2), alog10(disp_immin), alog10(disp_immax)), 2

       G.mxc = p[0]
       G.myc = p[1]

       rad = r_e
       checkmap = segmap2(p[0], p[1], rad)

       xcs = [G.axc, p[0]]
       ycs = [G.ayc, p[1]]
       loadct, 39
       contour, checkmap, levels=[10], xstyle=1, xrange=[0, G.npix], $
         ystyle=1, yrange=[0, G.npix], thick=3, color=254, /noerase

       oplot, xcs, ycs, psym=7, thick=3, color=254
       xx = [ fmin, p[0], p[1]]

       dxc = abs(G.axc - G.mxc)
       dyc = abs(G.ayc - G.myc)

       if ( dxc gt 5 OR dyc gt 5) then begin
           if (disp_interactive eq 1) then begin
               print, 'Moment ok?  0=no 1=yes'
               in1 = get_kbrd(1)
           endif else begin
               in1 = 0
           endelse


           if in1 eq 0 then begin
               print, 'dx,dy > 5; assuming Asym x,y center'
               xx = [fmin, G.axc, G.ayc]
                                ;read, xnew, PROMPT = 'new xcenter? '
                                ;read, ynew, PROMPT = 'new ycenter? '
                                ;xx = [fmin, xnew, ynew]
           endif else  xx = [ fmin, p[0], p[1]]
           
       endif else   xx = [ fmin, p[0], p[1]]
    
   endif else xx = [fmin, p[0], p[1]]

   return, xx
 end 
