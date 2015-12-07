; created 2/15/06
; J. Lotz
;
; modified 3/25/15
; J Lotz
; check that galaxy has flux in pixels


FUNCTION DOGALAXY_MOS, G
; calls astrolib functions
; 
; calls  morph.dat
; calls  pet_rad_cir2.pro
;        pet_rad_ellip2.pro
;        a_abs_min2.pro
;        a_abs2.pro
;        moment_min2.pro
;        moment2.pro
;        c_pet_cb2.pro
;        clumpy2.pro
;        gini2.pro
;        flux_pet_frac_ell2.pro
;        flux_pet_frac_cir2.pro
;        s2n_wht2.pro
;        segmap2.pro
;        checkmap.pro


COMMON galaxy_block, galaxy_image, galaxy_npix, galaxy_skybox, galaxy_psf, galaxy_scale, galaxy_e, galaxy_pa, galaxy_exptime, galaxy_display

;print, G.file
;xx = mrdfits("gal10.fits", 0)
galaxy_image = mrdfits(G.file, 0)
print, G.file
;Remove NaNs
rimg_nan = where(finite(galaxy_image, /NAN) eq 1)
if (size(rimg_nan, /DIMENSIONS) gt 1) then  galaxy_image[rimg_nan] = -99

fileroot = strsplit(G.file, '.', /extract)
;galaxy_wht = fileroot[0] + '_wht.fits'
;galaxy_exp = fileroot[0] + '_exp.fits'

galaxy_npix = G.npix
galaxy_psf = G.psf
galaxy_scale = G.scale
galaxy_e = G.e
galaxy_pa = G.pa
galaxy_skybox = G.skybox
galaxy_exptime = G.exptime
galaxy_display = G.display

root = strsplit(G.file, '.', /extract) ;
segfile = strjoin(root, '_seg2.')
mid_segfile = strjoin(root, '_MID_seg.')

; display galaxy image
if (galaxy_display eq 1) then begin
    @morph.dat

    COMMON display_block, disp_dw, disp_immin, disp_immax, disp_ct, disp_interactive
    disp_dw = dw
    disp_immin = immin * galaxy_exptime
    disp_immax = immax * galaxy_exptime
    disp_ct = color
    disp_interactive = interactive

    px = 0
    py = 0
    nx =3
    ny =1 
    xs = 3*disp_dw
    ys = dw
    dx1 = 0.0
    dy1 = 0.0

    pxmin  = (px * xs/nx)  + dx1
    pxmax  = pxmin + disp_dw
    pymin  = (py * ys/ny)  + dy1
    pymax =  pymin + disp_dw

    window, 0, xsize= 3*disp_dw, ysize=disp_dw
    loadct, color
    galaxy_image2 = frebin(galaxy_image, disp_dw, disp_dw)

    tv, bytscl(alog10(galaxy_image2), alog10(disp_immin), alog10(disp_immax)), 0

    !p.position=[pxmin/xs, pymin/ys, pxmax/xs, pymax/ys]

    loadct, 39     
    dist_circle, cir, galaxy_npix, G.axc, G.ayc
    contour, cir,  xstyle=1, xrange=[0, G.npix], $
      ystyle=1, yrange=[0, G.npix], thick=2, color=224, /noerase, /nodata 
endif        


;start morph analysis

; check that galaxy has flux in pixels
; kill if >10% of segmap pixel have 0 exptime
;goodpix = checkpix(galaxy_exp)

;print, "goodpix is ", goodpix

;if goodpix eq 0 then begin
;   print, "bad expmap ", galaxy_exp, ";  skipping galaxy "

;   xx =[-99, -99,  -99,  -99,  -99, -99, -99, -99, -99, -99, -99, -99, -99, -99, -99, -99 , -99, -99, -99, -99, -99, -99, -99, -99, -99, -99, ;-99, -99, -99, -99, -99, -99] 
;endif else begin
 
print, "getting morphologies for galaxy "

;inital r_cir, xc,yc 
r_cir = pet_rad_cir2(0.2, G)
if (r_cir lt 5*galaxy_psf/galaxy_scale) then begin 
    r_cir = pet_rad_cir_hres2(0.2, G) 
endif 
print, "new r_p = ", r_cir
 

if (galaxy_display eq 1) then begin

    px = 1
    py = 0
    pxmin  = (px * xs/nx)  + dx1
    pxmax  = pxmin + disp_dw
    pymin  = (py * ys/ny)  + dy1
    pymax =  pymin + disp_dw
    !p.position=[pxmin/xs, pymin/ys, pxmax/xs, pymax/ys]
    tv, bytscl(alog10(galaxy_image2), alog10(disp_immin), alog10(disp_immax)), 1

    dist_circle, cir, galaxy_npix, G.axc, G.ayc
    contour, cir, levels=[1.5*r_cir],  xstyle=1, xrange=[0, G.npix], $
      ystyle=1, yrange=[0, G.npix], thick=2, color=224, /noerase

    xcs =[G.axc]
    ycs =[G.ayc]
    oplot, xcs, ycs, psym=7, thick=3, color=224

    px = 2
    py = 0
    pxmin  = (px * xs/nx)  + dx1
    pxmax  = pxmin + disp_dw
    pymin  = (py * ys/ny)  + dy1
    pymax =  pymin + disp_dw
    !p.position=[pxmin/xs, pymin/ys, pxmax/xs, pymax/ys]

endif
  
if (r_cir lt 1) then r_cir = 1.
a = a_abs_min2(G, r_cir, galaxy_display) 
G.axc = a[1] 
G.ayc = a[2] 

; final r_cir, axc, ayc
r_cir = pet_rad_cir2(0.2, G) 
if (r_cir lt 5*galaxy_psf/galaxy_scale) then begin 
    r_cir = pet_rad_cir_hres2(0.2, G) 
endif 

if (r_cir lt 1) then r_cir = 1.
a = a_abs_min2(G, r_cir, galaxy_display) 
G.axc = a[1] 
G.ayc = a[2] 
G.mxc = a[1] 
G.myc = a[2] 

; r_ellp, mxc, myc
r_ellip = pet_rad_ellip2(0.2, G) 
if (r_ellip lt 5*galaxy_psf/galaxy_scale) then begin 
    r_ellip = pet_rad_ellip_hres2(0.2, G) 
endif 

print, r_cir, r_ellip
if (r_ellip le 2) then r_ellip = r_cir
if finite(r_ellip, /NAN) then begin
   r_ellip = r_cir
   print, "r_ellip is NaN"
endif

m = moment_min2(G, r_ellip, galaxy_display) 
G.mxc = m[1] 
G.myc = m[2]

print, "Calculating Concentration..."
cc = c_pet_cb_hres2(G, galaxy_display)
 
if (r_cir lt 5*galaxy_psf/galaxy_scale) then begin 
    s = clumpy_hres2(G, galaxy_display) 
endif  else begin 
     s = clumpy2(G, galaxy_display) 
endelse 

print, "Calculating Gini..."
gg = gini2(G, r_ellip, galaxy_display) 
print, "Calculating M20..."
mhi = moment_20_2(G, r_ellip, galaxy_display)

print, "Calculating r_half_e..."
if (r_ellip lt 5*galaxy_psf/galaxy_scale) then begin 
   r_half_e = flux_pet_frac_ell_hres2(0.5, r_ellip, G) 
   flux_half = flux_pet_ell3(r_half_e, G)
endif  else begin 
   r_half_e = flux_pet_frac_ell2(0.5, r_ellip, G)
   flux_half = flux_pet_ell3(r_half_e, G)

endelse  

print, "Calculating r_half_c..."
if (r_cir lt 5*galaxy_psf/galaxy_scale) then begin 
    r_half_c = flux_pet_frac_cir_hres2(0.5, r_cir, G) 
endif  else begin 
    r_half_c = flux_pet_frac_cir2(0.5, r_cir, G) 
endelse 



print, "Calculating segmap..."
seg = segmap2(G.mxc, G.myc, r_ellip) 
print, "Writing segfile..."
writefits, segfile, seg 

print, "Calculating S/N..."
sn = s2n_wht2(galaxy_image, galaxy_exptime, seg)
print, 'S/N = ', sn, ' R_ell = ', r_ellip*G.scale
 
galmap= where(seg gt 0)
isoflux = total(galaxy_image(galmap)) 
isomag = 2.5*alog10(isoflux) 

flagseg = checkmap(seg, G.mxc, G.myc) 

;***********************************************
; NEW MID STATISTICS
;***********************************************

; read in 84x84 postage stamp for sample H-band image
;img = readfits('ERS_2072_h.fits',h,/NOSCALE)

; compute the segmentation map based on algorith of Freeman et al. (section 4.3)
mid_seg = gen_segmap(galaxy_image,ETA=0.2,THRLEV=10)   ; default parameters set here

print, "Writing MID segfile..."
;writefits, mid_segfile, mid_seg

; create segmentation-masked image
img = galaxy_image*mid_seg
;img = galaxy_image*seg

; set pixels of negative intensity to zero
negative_intensity = where(img lt 0)
if (n_elements(negative_intensity) gt 1 ) then img[negative_intensity]=0

; compute the M statistic (assume default levels)
out = m_statistic(img)
M = out.M
a1 = out.a1 ;Area of largest clump
a2 = out.a2 ;Area of second largest clump
level = out.level
m_prime = a2/a1

; compute the I statistic, pre-smoothing the data with 1-pixel Gaussian kernel
out = i_statistic(img,SCALE=1)
I = out.I
xpeak = out.x
ypeak = out.y


; compute the D statistic, utilitizing output from I_STATISTIC
out_D = d_statistic(img,out.x,out.y)
D = out_D.D
nseg = out_D.nseg ;Number of pixels in segmmentatation map from gen_segmap()
xcen = out_D.xcen
ycen = out_D.ycen
Dprime = out_D.Dprime/r_ellip

print, 'M = ', M
print, 'I = ', I
print, 'D = ', D

;print, G.file, sn, r_half_c, r_half_e, r_cir, r_ellip, G.axc, G.ayc, G.mxc, G.myc, cc, a[0], s, gg[0], alog10(mhi) 

help, flux_half
xx =[sn, r_half_c,  r_half_e,  r_cir,  r_ellip, G.axc, G.ayc, G.mxc, G.myc, cc, a[0], s, gg[0], alog10(mhi), flagseg, n_elements(galmap),M,I,D,flux_half,a1,a2,nseg,level,xpeak,ypeak,xcen,ycen,Dprime,m_prime] 




return, xx 
 
end 
