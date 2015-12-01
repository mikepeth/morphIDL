PRO run_gmorph

big_xpix = 21443
big_ypix = 48483
im_psf = 0.12
im_scale = 0.03
zeropt = 26.486    ; EGS V 26.486  I 25.937  H 25.96  J 26.25
exptime = 1.0

get_gmorph_v1, '/user/lotz/candels/cosmos/acs/cos2e_acs_jen_m24.5.cat', $
'/user/lotz/candels/cosmos/acs/cos2e_acs_f606w_030mas_drz.trim.fits', $
'/user/lotz/candels/cosmos/acs/cos2e_wfc3_f160w_030mas_seg.fits', $
'/user/lotz/candels/cosmos/acs/cos2e_acs_f606w_030mas_jen_2.morph', $
big_xpix, big_ypix,im_psf,im_scale,zeropt,exptime




exit

;END
