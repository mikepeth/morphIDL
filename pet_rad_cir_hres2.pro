FUNCTION PET_RAD_CIR_HRES2, eta, G

 COMMON galaxy_block
 r_img = galaxy_image

  ; calculate petrosian radius in circular aps
  ; re-bins image to larger grid to improve precision

 ; rebin image
 size = 1000.0
 r_img2 = frebin(r_img, size, size) 
 xc = size/float(G.npix)* G.axc
 yc = size/float(G.npix)* G.ayc
 
 ; get circular apertures
 dist_circle, cir, size, xc, yc
 ;cir =float(G.npix)/size * cir
 
 ; initialize arrays
 total_int = fltarr(size)
 mu = fltarr(size)
 radius = fltarr(size)
 

 ; start computing curve of growth
 j = 0
 sum_int = 0
 R_pet = 1.0
 n= FLOAT(size)
 R_pet2 = fltarr(size) 

 FOR r=1.0, n-1, 1.0 DO BEGIN
     R_petold = R_pet
     ap = where (cir lt r)
     ap_08 = where ( cir lt r-1)
     ap_12 = where ( cir lt r+1)
     total_int[j] = total( r_img2(ap))
     if(N_ELEMENTS(ap_08) gt 1) then begin
         area = float(N_ELEMENTS( r_img2(ap_12))  - N_ELEMENTS(r_img2(ap_08)))

         if (area lt 2) then begin 
             mu[j] = 0.0
         endif else begin
             mu[j] = (total( r_img2(ap_12)) - total(r_img2(ap_08)))/area
         endelse

     endif else begin 
         area = float( N_ELEMENTS( r_img2(ap_12)))
         mu[j] = (total( r_img2(ap_12)))/area
     endelse    
  
     if(mu[j] lt 0) then mu[j] = 0.0

     if(j eq 0) then begin 
         sum_int = mu[j]* 3.1416 *(r + 0.5)^2 
     endif else begin 
         sum_int = sum_int + mu[j]* 3.1416 *((r + 0.5)^2 - (r - 0.5)^2) 
     endelse

     total_int[j] = sum_int
     avg_mu = sum_int/ 3.1416/ (r+0.5)^2 

     R_pet = mu[j]/avg_mu     
     R_pet2[j] = R_pet

     radius[j] = r

     if (R_pet lt eta) then begin  ; interpolate R_pet
         r_pet = r -r*(eta - R_pet) 
	 r = n+1.0
     endif
     j = j+1

 endfor     

 
 ;print, R_petold, r_pet

 !p.multi=[0, 1, 1]
 ; plot, (radius[0:j-1])^0.25, ALOG(mu[0:j-1]), /noerase
 
 ;plot, (radius[0:j-1]), (R_pet2[0:j-1]), xstyle=1, xrange=[0, 200], $
 ;                 yrange=[0, 1], ystyle=1, /noerase

return, r_pet*float(G.npix)/1000.0

end
