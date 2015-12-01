PRO run_gmorph_cos_h2

big_xpix = 14000 
big_ypix =36000 
im_psf = 0.12
im_scale = 0.06
zeropt = 25.96  ;  V 26.486  I 25.937  H 25.96  J 26.25 F105W 26.2687 F098m
exptimefile = '/user/lotz/candels/cosmos/wfc3/cos_2epoch_wfc3_f160w_060mas_v1.0_exp.fits'
nchunk = 2


startchunk=1
get_gmorph_acs_v3,  0, '/user/lotz/candels/cosmos/wfc3/cosmos_wfc3_f160w_60mas_badc.cat', $
'/user/lotz/candels/cosmos/wfc3/cos_2epoch_wfc3_f160w_060mas_v1.0_drz.fits', $
'/user/lotz/candels/cosmos/wfc3/cos_2epoch_wfc3_f160w_060mas_v1.0_wht.fits', $
'/user/lotz/candels/cosmos/wfc3/cos2e_f160w_seg.fits', $
'/user/lotz/candels/cosmos/wfc3/cos_wfc3_f160w_060mas_badc1.morph', $
big_xpix, big_ypix,im_psf,im_scale,zeropt,exptimefile, nchunk, startchunk


startchunk=2
get_gmorph_acs_v3,  0, '/user/lotz/candels/cosmos/wfc3/cosmos_wfc3_f160w_60mas_badc.cat', $
'/user/lotz/candels/cosmos/wfc3/cos_2epoch_wfc3_f160w_060mas_v1.0_drz.fits', $
'/user/lotz/candels/cosmos/wfc3/cos_2epoch_wfc3_f160w_060mas_v1.0_wht.fits', $
'/user/lotz/candels/cosmos/wfc3/cos2e_f160w_seg.fits', $
'/user/lotz/candels/cosmos/wfc3/cos_wfc3_f160w_060mas_badc2.morph', $
big_xpix, big_ypix,im_psf,im_scale,zeropt,exptimefile, nchunk, startchunk



exit

;END
