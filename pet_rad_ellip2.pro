FUNCTION PET_RAD_ELLIP2, eta, G
  ; compute petrosian radius in ellipses
 
 COMMON galaxy_block
 size= galaxy_npix
 r_img2 = galaxy_image
 xc = G.axc
 yc = G.ayc

 ; compute elliptical apertures
 ab = galaxy_e
 if (ab gt 6.0) then ab=6.0
 dist_ellipse, ell, size, xc, yc, ab, galaxy_pa


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
 FOR r=1.0, n-1, 1.0 DO BEGIN
     R_petold = R_pet
     ap = where (ell lt r)
     ap_08 = where ( ell lt r-1)
     ap_12 = where ( ell lt r+1)
   ;  print, r, G.e, N_ELEMENTS(ap_08), N_ELEMENTS(ap_12)
     if(N_ELEMENTS(ap_08) gt 1) then begin
         area = float(N_ELEMENTS( r_img2(ap_12))  - N_ELEMENTS(r_img2(ap_08)))
         total_int[j] = total( r_img2(ap))
         if (area lt 2) then begin 
             mu[j] = 0.0
         endif else begin
             mu[j] = (total( r_img2(ap_12)) - total(r_img2(ap_08)))/area
         endelse

     endif else begin 
         total_int[j] = total( r_img2(ap_12))
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
    ; print, radius[j], total_int[j], mu[j], R_pet, area

     r_ell = r
     if (R_pet lt eta) then begin  ; interpolate r_pet
         r_ell = r -r*(eta - R_pet) 
	 r = n+1.0
     endif
     j = j+1

 endfor     
 
if (r_ell ge n-1) then begin
     x = min(R_pet2, low)
     r_ell = radius(low)
 endif


return, r_ell

end
