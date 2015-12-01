FUNCTION S2N_WHT2, img, expfiletime, map
 ; this function find the average signal per pixel / noise for galaxy
 ; within the petrosian radius using segmap

 ; get wht map
 ; wht2 = mrdfits(whtfile,0)

  exp = expfiletime
  ; if file_test(expfile) eq 1 then exp = mrdfits(expfile,0)
  ; if file_test(expfile) eq 0 then exp = 1.0
 ; fits_read, whtfile, wht2
 
 ; find signal
  ap = where (map gt 1.0, nn)

 img2 = img*exp ;Multiply by Exposure map

 zero = where(img2 lt 0)

 img2(zero) = 0.0

                                ;s2n= total( img2(ap)/sqrt(1/wht2(ap) + img2(ap)))/nn
 s2n= total(img2(ap))/nn

 ;print, median(1/wht2(ap)), s2n, nn

 return, s2n

end
