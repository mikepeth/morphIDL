FUNCTION checkpix,  expimg
 ; this function checks that <10% of pixels in galaxy segmap have 0 exptime 

  bad = where(expimg le 0., nbad)
  ntot_exp = n_elements(expimg)

  frac_bad = float(nbad)/float(ntot_exp)

  if frac_bad ge 0.1 then goodpix = 0 else goodpix = 1

  return, goodpix

end




