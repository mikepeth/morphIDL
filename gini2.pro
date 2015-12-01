FUNCTION GINI2, G, rpet, plot
 ; this function finds the Gini coefficient 
 ; with petrosian radius 

 COMMON galaxy_block
 r_img = galaxy_image

 ; get galaxy pixels
  map = segmap2(G.mxc, G.myc, rpet)
  gal = where(map gt 0.0, n)
 
  ; find total of abs. value of galaxy pixels
  r_img2 = abs(r_img(gal))
  total = total(r_img2)
 
  vector= fltarr(n)
  v = fltarr(n)

  ; rank order galaxy pixels
  vector = REFORM(r_img2, n)
  v =sort(vector)

  ; compute gini coefficient
  gini2 = 0.0    
  for i=1L, n DO BEGIN
        gini2 = gini2 + (2*i -n -1)* vector[v[i-1]]
  endfor
  
  gini2 = 1/total/(n-1) * gini2  ; final G


   if plot eq 1 then begin   ; plot new xcenter, ycenter 

       COMMON display_block
       r_img2 = frebin(r_img, disp_dw, disp_dw)
 
       loadct, 0
       tv, bytscl(alog10(r_img2), alog10(disp_immin), alog10(disp_immax)), 2

       loadct, 39
 
       contour, map, levels=[10], xstyle=1, xrange=[0, G.npix+1], $
         ystyle=1, yrange=[0, G.npix+1], thick=3, color=224, /noerase

       xyouts, 5, 5, "G"
 
       print, "Gini is ", gini2

       wait, 2


   endif

  gg= [gini2, n]

  return, gg

end
