FUNCTION C_PET_CB_HRES2, G,  plot
 ; calculates concentration (BCG 2000)
 ; return Concentration, r_20, r_80

COMMON galaxy_block

r_pet = pet_rad_cir2(0.2, G)

;if (r_pet lt 5*G.psf/G.scale) then begin
r_pet = pet_rad_cir_hres2(0.2, G)
r_20 = FLUX_PET_FRAC_CIR_HRES2( 0.20, r_pet, G)
r_80 = FLUX_PET_FRAC_CIR_HRES2( 0.80, r_pet, G)
;endif else begin
;    r_20 = FLUX_PET_FRAC_CIR2( 0.20, r_pet, G)
;    r_80 = FLUX_PET_FRAC_CIR2( 0.80, r_pet, G)
;endelse

c = 5*ALOG10(r_80/r_20)

cc = [c, r_20, r_80]

if plot eq 1 then begin         ; plot new xcenter, ycenter 

       COMMON display_block
       I = galaxy_image
       I2 = frebin(I, disp_dw, disp_dw)

       loadct, 0
       tv, bytscl(alog10(I2), alog10(disp_immin), alog10(disp_immax)), 2

       loadct, 39
       dist_circle, cir, G.npix, G.axc, G.ayc
       contour, cir, levels=[r_20, r_80], xstyle=1, xrange=[0, G.npix], $
         ystyle=1, yrange=[0, G.npix], thick=3, color=224, /noerase 

       xyouts, 5, 5, "C"

       print, "Concentration is ", c

  endif

return, cc  

end
