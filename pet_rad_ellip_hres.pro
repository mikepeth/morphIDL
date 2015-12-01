FUNCTION PET_RAD_ELLIP_HRES, eta, G, r_img
  ; compute petrosian radius in ellipses
  ; regrid image to large scales
 
 ; rebin image
 size = 1000.0
 r_img2 = frebin(r_img, size, size) 
 xc = size/float(G.npix)* G.axc
 yc = size/float(G.npix)* G.ayc

 ; compute elliptical apertures
 ab = G.e
 if (ab gt 6.0) then ab=6.0
 dist_ellipse, ell, size, xc, yc, ab, G.pa
 ;ell =float(G.npix)/size * ell  

 ; initialize arrays
 total_int = fltarr(long(size))
 mu = fltarr(long(size))
 radius = fltarr(long(size))
 
 j = 0
 sum_int = 0
 R_pet = 1.0
 n= FLOAT(long(size))
 R_pet2=fltarr(long(size))
 
 ; compute curve of growth
 FOR r=2.0, n, 1.0 DO BEGIN
     R_petold = R_pet
     ap = where (ell lt r)
     ap_08 = where ( ell lt r-1)
     ap_12 = where ( ell lt r+1)
     total_int[j] = total( r_img2(ap))
     if(N_ELEMENTS(ap_08) gt 1) then begin
         area = float(N_ELEMENTS( r_img2(ap_12))  - N_ELEMENTS(r_img2(ap_08)))

         if (area lt 2) then begin 
             mu[j] = 0.0
         endif else begin
             mu[j] = (total( r_img2(ap_12)) - total(r_img2(ap_08)))/area
         endelse

     endif else begin 
         area = float(N_ELEMENTS( r_img2(ap_12)))
         mu[j] = total( r_img2(ap_12))/area
     endelse    
  
     if(mu[j] lt 0) then mu[j] = 0.0

     if(j eq 0) then begin 
         sum_int = mu[j]* 3.1416 *(r + 0.5)^2 /G.e
     endif else begin 
         sum_int = sum_int + mu[j]* 3.1416 *((r + 0.5)^2 - (r - 0.5)^2)/G.e 
     endelse

     total_int[j] = sum_int
     avg_mu = sum_int/ 3.1416/ (r+0.5)^2 * G.e

     R_pet = mu[j]/avg_mu     
     R_pet2[j]= mu[j]/avg_mu 
     radius[j] = r
     ;print, radius[j], total_int[j], mu[j], R_pet, area

     if (R_pet lt eta) then begin  ; interpolate r_pet
         r_pet = r -r*(eta - R_pet) 
	 r = n+1.0
     endif
     j = j+1

 endfor     

;plot, radius*float(G.npix)/1000.00, R_pet2, psym=1, xstyle=1, xrange=[0, 100]


return, r_pet*float(G.npix)/1000.00

end
