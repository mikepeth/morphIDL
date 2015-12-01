PRO run_gmorph

big_xpix = 960
big_ypix = 960
im_psf = 1.0
im_scale = 0.25
zeropt = 24.4    ; EGS V 26.486  I 25.937  H 25.96  J 26.25

location = '/astro/candels2/user/mikepeth/panstarrs/UGC/'

galFiles= file_search(location+'*white.fits')
Ngals = size(galFiles,/DIMENSIONS)

for img=0, Ngals[0]-1  do begin
   baseName = strsplit(galFiles[img],'.',/EXTRACT)
   print, baseName
   get_gmorph_v1, basename[0]+'_cold_fix.cat', $
                  galFiles[img], $
                  basename[0]+'_cold_seg.fits', $
                  basename[0]+'.morph', $
                  big_xpix, big_ypix,im_psf,im_scale,zeropt
endfor
;exit
END
