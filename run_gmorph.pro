PRO run_gmorph

big_xpix = 960
big_ypix = 960
im_psf = 1.0
im_scale = 0.25
zeropt = 24.4    ; EGS V 26.486  I 25.937  H 25.96  J 26.25

location = '/astro/candels2/user/mikepeth/panstarrs/UGC/'

get_gmorph_v1, location+'UGC00333_white_cold_fix.cat', $
location+'UGC00333_white.fits', $
location+'UGC00333_white_cold_seg.fits', $
location+'test_00333.morph', $
big_xpix, big_ypix,im_psf,im_scale,zeropt

exit

END
