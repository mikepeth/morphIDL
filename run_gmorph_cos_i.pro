PRO run_gmorph_cos_i

big_xpix = 21443
big_ypix = 48483
im_psf = 0.12
im_scale = 0.03
zeropt = 25.937     ; EGS V 26.486  I 25.937  H 25.96  J 26.25
exptimefile = '/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_exp.trim.fits'
nchunk = 4


;startchunk=1

;get_gmorph_acs_v3,  5638, '/user/lotz/candels/cosmos/acs/cos2e_acs_jen_m24.5.cat', $
;'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_drz.trim.fits', $
;'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_wht.trim.fits', $
;'/user/lotz/candels/cosmos/acs/cos2e_wfc3_f160w_030mas_seg.fits', $
;'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_jen_1_v2.morph', $
;big_xpix, big_ypix,im_psf,im_scale,zeropt,exptimefile, nchunk, startchunk

startchunk=2
get_gmorph_acs_v3,  15854, '/user/lotz/candels/cosmos/acs/cos2e_acs_jen_m24.5.cat', $
'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_drz.trim.fits', $
'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_wht.trim.fits', $
'/user/lotz/candels/cosmos/acs/cos2e_wfc3_f160w_030mas_seg.fits', $
'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_jen_2.morph', $
big_xpix, big_ypix,im_psf,im_scale,zeropt,exptimefile, nchunk, startchunk

;startchunk=3
;get_gmorph_acs_v3,  18757, '/user/lotz/candels/cosmos/acs/cos2e_acs_jen_m24.5.cat', $
;'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_drz.trim.fits', $
;'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_wht.trim.fits', $
;'/user/lotz/candels/cosmos/acs/cos2e_wfc3_f160w_030mas_seg.fits', $
;'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_jen_3.morph', $
;big_xpix, big_ypix,im_psf,im_scale,zeropt,exptimefile, nchunk, startchunk

;startchunk=4
;get_gmorph_acs_v3, 0, '/user/lotz/candels/cosmos/acs/cos2e_acs_jen_m24.5.cat', $
;'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_drz.trim.fits', $
;'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_wht.trim.fits', $
;'/user/lotz/candels/cosmos/acs/cos2e_wfc3_f160w_030mas_seg.fits', $
;'/user/lotz/candels/cosmos/acs/cos2e_acs_f814w_030mas_jen_4.morph', $
;big_xpix, big_ypix,im_psf,im_scale,zeropt,exptimefile, nchunk, startchunk


exit

;END
