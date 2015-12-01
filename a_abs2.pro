 FUNCTION A_ABS2, X

    xc = X[0]  
    yc = X[1]  
    r_e = X[2] 

    COMMON galaxy_block
    
    if( xc gt 0 AND xc lt galaxy_npix AND yc gt 0 AND yc lt galaxy_npix) then begin
        ds = (galaxy_skybox[1] - galaxy_skybox[0])/2 

        rimg_180 = rot(galaxy_image, 180, 1.0, xc, yc, /INTERP, /PIVOT, MISSING=0.0) 
        bkg_img = galaxy_image[galaxy_skybox[0]:galaxy_skybox[1], galaxy_skybox[2]:galaxy_skybox[3]] 

        dist_circle, cir, galaxy_npix, xc, yc 
        ap = where (cir lt 1.5*r_e) 

        I_dif = galaxy_image - rimg_180  
        I_dif2 = I_dif(ap)  
        I = galaxy_image(ap) 

        norm= float( N_ELEMENTS(I)) 
        bkg_180 = rot( bkg_img, 180, 1.0,  ds, ds, /INTERP, /PIVOT, MISSING=0.0)
        a_bkg =  total(abs(bkg_img - bkg_180))/float(N_ELEMENTS(bkg_img))
        a_gal =  total(abs(I_dif2))/total(abs (I)) 
        asym = a_gal- norm *a_bkg/ total(abs(I)) 
    endif else asym=99
   ; print, asym, xc, yc 

return, asym 
 end 
