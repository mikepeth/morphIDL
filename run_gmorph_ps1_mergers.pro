PRO run_gmorph_manga

big_xpix = 960
big_ypix = 960
im_psf = 1.0
im_scale = 0.25
zeropt = 24.4    ; EGS V 26.486  I 25.937  H 25.96  J 26.25
;              24.563

location = '/Users/mikepeth/Desktop/ps1mergers/'

galFiles= file_search(location+'*white.fits')
Ngals = size(galFiles,/DIMENSIONS)

;090430.6+515644 has a segmap problem, gal=98
;095559.3+395438, gal=148
;110508.0+283657 galaxy has a weird white image with no segmentations, gal=240
;113330.9+564431, gal=275
;120045.2+570801, gal=312
;WHERE(STRMATCH(galFiles, '*110508.0+283657*', /FOLD_CASE) EQ 1)

for img=313, Ngals[0]-1  do begin
   baseName = strsplit(galFiles[img],'.',/EXTRACT)
   ;print, baseName[1]
   fullbasename = baseName[0]+'.'+baseName[1]
   print, fullbasename
   gband = fullbasename.Remove(-5) ;Removes 'white' from the filename
   print, gband
   get_gmorph_manga, fullbasename+'_cold_primary.cat', $
                  ;galFiles[img], $
                gband+'g.fits', $
   				gband+'g.wt.fits', $
                fullbasename+'_cold_seg.fits', $
   	            fullbasename+'_gband_full3.morph', $
                big_xpix, big_ypix,im_psf,im_scale,zeropt

endfor
;exit
END
