PRO run_gmorph_manga

big_xpix = 480 ;960
big_ypix = 480 ;960
im_psf = 1.0
im_scale = 0.25
zeropt = 24.4    ; EGS V 26.486  I 25.937  H 25.96  J 26.25

location = '/user/mikepeth/manga/'

galFiles= file_search(location+'*white.fits')
Ngals = size(galFiles,/DIMENSIONS)

for img=0, Ngals[0]-1  do begin
   baseName = strsplit(galFiles[img],'.',/EXTRACT)
   gband = baseName[0].Remove(-5) ;Removes 'white' from the filename
   get_gmorph_manga, basename[0]+'_cold_primary.cat', $
                  ;galFiles[img], $
                  gband+'g.00000.fits', $
                  basename[0]+'_cold_seg.fits', $
   	              basename[0]+'_gband.morph', $
                  big_xpix, big_ypix,im_psf,im_scale,zeropt
endfor
;exit
END
