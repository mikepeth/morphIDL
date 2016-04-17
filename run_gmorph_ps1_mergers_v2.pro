PRO run_gmorph_ps1

big_xpix = 960
big_ypix = 960
im_psf = 1.0
im_scale = 0.25
zeropt = 24.4    ; EGS V 26.486  I 25.937  H 25.96  J 26.25
;              24.563

location = '/Users/mikepeth/Desktop/ps1mergers/'

galFiles= file_search(location+'*white.fits')
Ngals = size(galFiles,/DIMENSIONS)

;110508.0+283657 galaxy has a weird white image with no segmentations, gal=240
;WHERE(STRMATCH(galFiles, '*110508.0+283657*', /FOLD_CASE) EQ 1)

;090811.9+220014 segmap issues, gal=104
;094809.8+023221 segmap issues, gal=141
;151015.8+581042 segmap issues, gal=545
;152606.1+414014 segmap issues, gal=566

;020924.6-100809 missing partner galaxy (originally outside 350x700), gal=28
;094809.8+023221 missing partner galaxy (originally outside 350x700), gal=
;110951.4+241542 missing partner galaxy (originally outside 350x700), gal=
;

;094809.8+023221 broke upon re-measurement

;for img=567, Ngals[0]-1  do begin
readcol, 'ids_missing_morph.txt', ids, format='a' ;Grabs all the IDs needed to be re-measured
nids = size(ids,/dimensions)

for i=4, nids[0]-1 do begin
   img=WHERE(STRMATCH(galFiles, '*'+ids[i]+'*', /FOLD_CASE) EQ 1)

   baseName = strsplit(galFiles[img],'.',/EXTRACT)
   ;print, baseName[1]
   fullbasename = baseName[0]+'.'+baseName[1]
   print, fullbasename
   gband = fullbasename.Remove(-5) ;Removes 'white' from the filename
   print, gband
   get_gmorph_manga, fullbasename+'_cold_primary_100x800.cat', $
                  ;galFiles[img], $
                gband+'g.fits', $
   				gband+'g.wt.fits', $
                fullbasename+'_cold_seg.fits', $
   	            fullbasename+'_gband_primary_100x800.morph', $
                big_xpix, big_ypix,im_psf,im_scale,zeropt

endfor
;exit
END
