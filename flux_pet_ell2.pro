FUNCTION FLUX_PET_ELL2, rad, G
  ; calculates flux within given circular aperture

COMMON galaxy_block

rpet = rad
size = galaxy_npix
r_img2 = galaxy_image
xc = G.axc
yc = G.ayc

 ; compute elliptical apertures
dist_ellipse, ell, size, xc, yc, G.e, G.pa

 ; initialize arrays
total_int = fltarr(size)
mu = fltarr(size)
radius = fltarr(size)
output = fltarr(size, 2) 
 
; start loop
 j = 0
 sum_int =0
 R_pet = 1.0
 n= FLOAT(size)
 
 FOR r=1.0, n-1.0, 1.0 DO BEGIN
     ap = where (ell lt r)
     ap_08 = where ( ell lt r-1)
     ap_12 = where ( ell lt r+1)
     if (N_ELEMENTS(ap) gt 1) then begin
         total_int[j] = total( r_img2(ap))
     endif else total_int[j] = 0.0

     if(N_ELEMENTS(ap_08) gt 1) then begin
         area = float(N_ELEMENTS( r_img2(ap_12))  - N_ELEMENTS(r_img2(ap_08)))

         if (area lt 2) then begin 
             mu[j] = 0.0
         endif else begin
             mu[j] = (total( r_img2(ap_12)) - total(r_img2(ap_08)))/area
         endelse    
  
     endif else begin 
         area = float(N_ELEMENTS( r_img2(ap_12)))
         mu[j] = (total( r_img2(ap_12)))/area
     endelse    
 
     if(mu[j] lt 0) then mu[j] = 0

     if(j eq 0) then begin 
         sum_int = mu[j]* 3.1416 *(r + 0.5)^2
     endif else begin 
         sum_int = sum_int + mu[j]* 3.1416 *((r + 0.5)^2 - (r - 0.5)^2) 
     endelse
   
     radius[j] = r

    output[j,0] = r
    output[j,1] = sum_int

    ; print, radius[j], sum_int, mu[j], area
     if (r gt rad) then begin
         r = n+1.0
     endif 
     j = j+1

 endfor     

 flux_pet = sum_int       
 output[*,1] = output[*,1]/sum_int ;
 if (r lt rad) then print, 'Galaxy bigger than chip'

 return, sum_int

end
