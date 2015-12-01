FUNCTION getmu_apet, G, r_img, rpet
 
; find average surface brightness within pet radius

 fw = rpet/5

 if fw lt G.psf/G.scale then fw = 3*G.psf/G.scale
 
 if (fw lt 1.0) then fw = 1.0
 if (fw ne fw) then fw = 1.0 ;For when fw = -Nan
 npix_psf = long(5.0 * fw)

 psf = psf_gaussian( npixel=npix_psf, fwhm=fw, ndimen=2, /normal)
 cimg = convolve(r_img, psf)

 ; find surface brightness at petrosian radius
 dist_ellipse, ellip, G.npix, G.axc, G.ayc, G.e, G.pa  
 rad =  rpet
 ap = where (ellip le rad)
 
 if (ap[0] gt -1) then begin
 mu = avg(cimg(ap))
endif else begin
    mu = -99
endelse

return, mu
end
