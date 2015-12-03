FUNCTION SEGMAP2, xcenter, ycenter, rpet
 ; this function create segmentation map of galaxy
 ; based on surf brightness at petrosian sma (r_ellip) 
 
 COMMON galaxy_block
 r_img = galaxy_image

 ; smooth image by 1/5 petrosian radius
 fw = rpet/10.0
 if fw lt 3*galaxy_psf/galaxy_scale then fw = 3*galaxy_psf/galaxy_scale
 
 if (fw lt 1.0) then fw = 1.0
 if finite(fw,/NAN) then fw = 1.0
 if finite(fw,/INFINITY) then fw = 1.0
 npix_psf = long(5.0 * fw)

 psf = psf_gaussian( npixel=npix_psf, fwhm=fw, ndimen=2, /normal)

 ;Remove NaNs from r_img
 rimg_nan = where(r_img eq !VALUES.F_NAN)
 if (size(rimg_nan, /DIMENSIONS) gt 1) then  r_img[rimg_nan] = -99
 cimg = convolve(r_img, psf)

 ;Remove NaNs from cimg
 cimg_nan = where(cimg eq !VALUES.F_NAN)
 if (size(cimg_nan, /DIMENSIONS) gt 1) then  cimg[cimg_nan] = -99
 
 ; find surface brightness at petrosian radius

 dist_ellipse, ellip, galaxy_npix, xcenter, ycenter, galaxy_e, galaxy_pa 
 ap = where (ellip lt rpet+1.0 AND ellip gt rpet-1.0)

 if (ap[0] eq -1) then begin
     if( xcenter + rpet ge galaxy_npix OR ycenter + rpet ge galaxy_npix) then begin
         print, 'Xcenter = ', xcenter, ' Ycenter = ', ycenter 
         print, 'R_pet ', rpet, ' greater than image ', galaxy_npix 
     endif 
     segmap1 = cimg
     segmap1[*,*] = 10.
 endif else begin
     mu = avg(cimg(ap))

                                ; set pixel with flux < mu = 0.0 and  pixels with flux > mu = 10
     cimg2 = cimg
     sky= where(cimg lt mu, nsky)
     if nsky ne 0 then cimg2(sky) = 0.0

     gal = where(cimg2 gt 0.0, ngal)

     if ngal gt 0 then begin
        while ngal lt 2 do begin
           ;print, ngal
           mu = 2*mu
           cimg2 = cimg
           sky= where(cimg lt mu, nsky)
           if nsky ne 0 then cimg2(sky) = 0.0
           gal = where(cimg2 gt 0.0, ngal)
        endwhile
     endif
     
     cimg2(gal) = 10.0

                                ; remove outlying pixels
     seg = 10
     segmap1 = sigma_filter(cimg2, seg, /ALL_PIXELS)
     map1 = where(segmap1 gt 0.0)

    ; print, N_ELEMENTS(map1), xcenter, ycenter
     segmap1(map1) = 10.0
 endelse



 ; force segmap to be continguous
 segmap1[long(xcenter), long(ycenter)] = 10.0
 ;region = search2d(segmap1, long(xcenter), long(ycenter), 9.9, 10.1,  /diagonal)
 segmapb = segmap1
 ;segmapb[*,*] = 0.0
 ;segmapb(region) = 10.0

 return, segmapb

end

