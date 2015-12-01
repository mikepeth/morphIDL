FUNCTION MOMENT2, X 
  xcenter = X[0]
  ycenter = X[1]
  r_e = X[2]

  COMMON galaxy_block
  n = long(galaxy_npix) *long(galaxy_npix)
  mom_t = 0.0 

  if( xcenter gt 0 AND xcenter lt galaxy_npix AND ycenter gt 0 AND ycenter lt galaxy_npix) then begin

      map = segmap2(xcenter, ycenter, r_e) 
      gal = where(map gt 0.0, n2) 

      ii = dindgen(n) 
      ix = float(ii mod galaxy_npix) + 0.5  
      iy = float(ii)/ float(galaxy_npix) + 0.5  

      radius = fltarr(n)
      radius(gal) = sqrt( (ix(gal) - xcenter)^2 + (iy(gal) - ycenter)^2)  
 
      if (map[xcenter, ycenter] eq 10.0 AND N_ELEMENTS(gal) gt r_e) then begin
          moment = galaxy_image(gal)* radius(gal)^2
          mom_t = total(moment)
      endif else mom_t = 1e20
  endif else mom_t = 1e20

 ; print, mom_t, xcenter, ycenter, N_ELEMENTS(gal), r_e
  return, mom_t
end

