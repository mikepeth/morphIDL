FUNCTION FLUX_PET_ELL3, rad, G
  ; calculates flux within given circular aperture

COMMON galaxy_block

rpet = rad
size = galaxy_npix
r_img2 = galaxy_image
xc = G.axc
yc = G.ayc

 ; compute elliptical apertures
dist_ellipse, ell, size, xc, yc, G.e, G.pa

ap = where (ell le rpet)
sum_int = total(r_img2(ap))

if (size lt rad) then print, 'Galaxy bigger than chip'

return, sum_int

end
