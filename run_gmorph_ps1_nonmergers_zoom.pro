PRO run_gmorph_ps1_nonmergers2

big_xpix = 960
big_ypix = 960
im_psf = 1.0
im_scale = 0.25
zeropt = 24.4    ; EGS V 26.486  I 25.937  H 25.96  J 26.25
;              24.563

location = '/astro/lotz/peth/nonmergers/'

galFiles= file_search(location+'*white.fits')
Ngals = size(galFiles,/DIMENSIONS)

;WHERE(STRMATCH(galFiles, '*110508.0+283657*', /FOLD_CASE) EQ 1)
;003815.5-005802, gal=5, Array has a corrupted descriptor: XI.
;074529.7+321737, gal=69, segmap error
;081025.6+374353, gal=97, segmap error

for img=200, Ngals[0]-1  do begin
;readcol, 'ids_missing_morph.txt', ids, format='a' ;Grabs all the IDs needed to be re-measured
;nids = size(ids,/dimensions)

   ;img=WHERE(STRMATCH(galFiles, '*'+ids[i]+'*', /FOLD_CASE) EQ 1)

   baseName = strsplit(galFiles[img],'.',/EXTRACT)
   ;print, baseName[1]
   fullbasename = baseName[0]+'.'+baseName[1]
   print, fullbasename
   gband = fullbasename.Remove(-5) ;Removes 'white' from the filename
   print, gband
   get_gmorph_manga, fullbasename+'_cold_primary_300x700.cat', $
                  ;galFiles[img], $
                gband+'g.fits', $
   				gband+'g.wt.fits', $
                fullbasename+'_cold_seg.fits', $
   	            fullbasename+'_gband_primary_300x700.morph', $
                big_xpix, big_ypix,im_psf,im_scale,zeropt

endfor
;exit
END
