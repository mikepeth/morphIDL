;******************************************************************************
;******************************************************************************
; this program computes G, M20, C, A, S for mosaic fits images
;
; requires input catalog of objects to be measured, input mosaic
; image, weightmap, segmentation map (fits images)
; and external parameter file 'morph.dat'
;
; SExtractor catalog must be format 
; ID  MAG  MAGER  RA(eg)  DEC(deg)  XCENTER YCENTER XMIN XMAX YMIN YMAX ELONGATION(A/B) 
;
; to call:
; get_gmorph, starting galaxy number (0 for 1st galaxy), galaxy_catalog, mosaic_image, wht_image, seg_image, output_file
;
; J. Lotz  9/01/2005
;
; modified to use common block version (faster)
; J. Lotz 4/20/2006
;
;calls NASA astrolib functions
;
;******************************************************************************
;******************************************************************************

PRO get_gmorph_acs_v2, starti, sexcat, big_imfile, big_whtfile,big_segfile, outmorphs,big_xpix, big_ypix,im_psf,im_scale,zeropt,exptimefile, nchunk 

;********************************************************
; read files, initalize parameters
;*******************************************************
 
;read in morph.dat parameters
@morph.dat
;if (interactive eq 1) then 
display =0 

; read in SExtractor galaxy catalog
;readcol, sexcat, wid, ra_w, dec_w, z_w,  id,  ra, dec, xc, yc, xmin,
;xmax, ymin, ymax, ellip, pa,mag, mager, format='(I, F, F, F, F, F, F,
;F, F, F, F, F, F)'

readcol, sexcat,  id,  ra, dec, xc, yc, xmin, xmax, ymin, ymax, mag, mager, classstar,  pa, ellip, format='(l,f,f,f,f,i,i,i,i,f,f,f,f,f)'

; define galaxy structure
G={ file:' ', npix:0, axc:0.0, ayc:0.0, mxc:0.0, myc:0.0, $
    e:0.0, pa:0.0, psf:im_psf, scale:im_scale, bkgnd:0.0, $
    skybox:[0.0,0.0,0.0,0.0], exptime:1.0, display:display }

; read in images
;sbig = size(big_im)
;if big_im eq !NULL or sbig[0] eq 0 then begin

chunk=long(floor(big_ypix/4))
big_ymax = long(nchunk)*chunk
big_ymin = long(nchunk-1)*chunk

big_im=mrdfits(big_imfile, 0, range=[big_ymin, big_ymax])
big_segmap=mrdfits(big_segfile, 0, range=[big_ymin, big_ymax]) ;, /NO_UNSIGNED
big_wht=mrdfits(big_whtfile, 0, range=[big_ymin, big_ymax])
big_exp=mrdfits(exptimefile, 0, range=[big_ymin, big_ymax])
;endif


; open output file 
fmt_out = '( I9,  F15.7, F15.7, F12.3, E12.4,  F12.2,  F12.2,  F12.2,  F12.2,  F12.2,  F12.3,  F12.3,  F12.3,  F12.3,  F12.2,  F12.2,  F12.2, F12.2,  F12.2,  F12.2,  F12.2,  I4,  E12.3, I4,  F12.3,  F12.3,  F12.3,  F12.3,  F12.3,  F12.3,  F12.3, E12.3,F12.3,F12.3,F12.3,F12.3,F12.3,F12.3,F12.3,F12.3,F12.3,F12.3)'

openw, 3, outmorphs, /append
catalog_header, 3 ;Use file number 3

;printf, 3, '# ID    RA  DEC   SExMAG   MAGER   <S/N>   R1/2_cir  R1/2_ell  Rpet_cir  Rpet_ell   AXC   AYC    MXC   MYC   C  r20 r80   A    S    G   M20   FLAG  NPIX  TYPE  MAG_ISO   MU_ISO   MU_PET   MU_APET M I D Flux_pet_ell a1 a2 nseg'
;printf, 3, '# ( )   (deg)  (deg)  (mag) (mag)  (per pix)  (arcsec) (arcsec)  (arcsec) (arcsec) (pix) (pix) (pix) (pix)  ( ) (pix) (pix) ( )  ( )  ( )  ( ) ( )  (pix)   ( )  (mag)  (mag)  (mag)  (mag) () () () (counts) (pixels) (pixels) (pixels)'
;printf, 3, '# FLAG:   '

;xx =[sn, r_half_c,  r_half_e,  r_cir,  r_ellip, G.axc, G.ayc, G.mxc, G.myc, cc, a[0], s, gg[0], alog10(mhi), flagseg, n_elements(galmap),M,I,D,flux_pet_ell,a1,a2,nseg]


;************************************************************
; start main loop through galaxy catalog
;************************************************************

n = N_ELEMENTS(id)
;n=starti+1

if (starti eq 0) then begin
    i = 0
endif else begin
    iarray = where(id ge starti)
    i = iarray[0]
    n = n_elements(id)-i
endelse


while(i lt n) do begin

    ;***************************************
    ; initalize galaxy parameters
    ;**************************************

    print, 'starting galaxy ', id[i]


    ; set galaxy file names
    galfile = 'gal'+ string(id[i], format='(I0)') + '.fits'
    galwhtfile = 'gal'+ string(id[i], format='(I0)') + '_wht.fits'
    galsegfile = 'gal'+ string(id[i], format='(I0)') + '_seg2.fits'
    galseg1file = 'gal'+ string(id[i], format='(I0)') + '_seg1.fits'
    galexpfile = 'gal'+ string(id[i], format='(I0)') + '_exp.fits'


    ; set galaxy structure values
    G.file = galfile
    ;G.exptime = exptime G.exptime = 1
    G.display = display

    if (ellip[i] lt 1.0) then begin
        G.e = 1.0 / ( 1.0 - ellip[i]) ; need a/b    
    endif else begin
        G.e = ellip[i]
    endelse
    if (G.e gt 4.0) then G.e=4.0 
    G.pa =  pa[i] + 90  ; convert SExtractor PA to IDL PA  


    ; set default output values   FLAG=1  TYPE=6  SN = 0.0
    out = [id[i], ra[i], dec[i], mag[i], mager[i],  0.0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 6,  0.00, 0.00, 0.00, 0.00,0.00,0.00,0.00,0.00,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    type=6

 
   ;******************************************************
   ; get galaxy postage stamps for img, segmap, and whtmap
   ;******************************************************

    dx = (xmax[i] - xmin[i])/2.0
    dy = (ymax[i] - ymin[i])/2.0

    if (dx gt dy) then dy=dx else dx=dy  ; make square region

    if ( (xc[i] - dx lt 0) or (xc[i] + dx gt big_xpix) $   ; check if galaxy is on image edge
          or (yc[i] - dy lt big_ymin) or (yc[i] + dy gt big_ymax)) then begin
      
        if( interactive eq 1) then begin
            print, 'Galaxy on image edge; Next galaxy?  0=no 1=yes'
            in = get_kbrd(1)
 
            if (in eq 1) then i=i+1 else i=n
        endif else i=i+1

    endif else begin   ; do galaxy morphs

        ; make postage stamp
        if (xc[i]+dx+dim gt big_xpix-1) then begin
            xmax2 = big_xpix -1.0 
            xmin2 = big_xpix -1.0 - 2*dx - 2*dim 
            xc2 = xc[i] - xmin2
        endif else begin
            if( xc[i] - dx - dim lt 0) then begin
                xmin2 = 0.0
                xmax2 = 2*dx +2*dim
                xc2 = xc[i] 
            endif else begin
                xmin2 = xc[i] - dim - dx
                xmax2 = xmin2 + 2*dx + 2*dim
                xc2 = dx + dim
            endelse
        endelse

        if (yc[i]+dy+dim gt big_ymax-1) then begin
            ymax2 =  big_ymax - 1.0
            ymin2 = big_ymax -1.0 - 2*dx - 2*dim 
            yc2 = yc[i] - ymin2
        endif else begin
            if( yc[i] - dy - dim lt big_ymin) then begin
                ymin2 = big_ymin
                ymax2 = 2*dy + 2*dim
                yc2 = yc[i] - ymin2
            endif else begin
                ymin2 = yc[i] - dim - dy 
                ymax2 = ymin2 + 2*dy + 2*dim
                yc2 = dy + dim
            endelse
        endelse

        print, xmin2, xmax2, ymin2, ymax2
        xmin2 = long(xmin2)
        xmax2 = long(xmax2)
        ymin2 = long(ymin2) - big_ymin
        ymax2 = long(ymax2) - big_ymin

        yc2 = yc2

        
        sm_img = big_im[xmin2:xmax2, ymin2:ymax2]
        gal_seg = big_segmap[xmin2:xmax2, ymin2:ymax2] ;YEAH! removed long cast
        gal_wht = big_wht[xmin2:xmax2,ymin2:ymax2]
        gal_exp = big_exp[xmin2:xmax2, ymin2:ymax2]
        ;sm_img = sm_img * G.exptime   
        ;gal_wht = gal_wht/ G.exptime


        ; set inital xcenter, ycenter for stamps
        G.axc=xc2
        G.ayc=yc2
        G.mxc=xc2
        G.myc=yc2
        G.npix = xmax2 - xmin2 + 1
    
        ;********************************************************
        ; start interactive mode 
        ;********************************************************

        ; display postage stamps for interactive mode
        if (display eq 1) then begin   
            disp_immin =  immin 
            disp_immax =  immax
           ; dw= G.npix 
       
            imscale = long(round(float(dw)/float(G.npix)))
            imscale2 = float(dw)/float(G.npix)

            window, 0, xsize= 3*dw, ysize=dw

            sm_img2 = frebin(sm_img, dw, dw)
            gal_seg2= congrid(gal_seg, dw, dw)

            loadct, color
            tv, bytscl(alog10(sm_img2), alog10(disp_immin), alog10(disp_immax)), 0
	endif        

        galsegmap = where(gal_seg gt 0) ; ALL MODES 
        ;min_galseg = min(gal_seg(galsegmap))
        ;max_galseg = max(gal_seg(galsegmap))

        if (display eq 1) then begin 
                loadct, 23
        	tv, bytscl(gal_seg2, id[i]-500, id[i]+500 ), 1      
        endif 
        
        
        ; continue with galaxy?
        if (interactive eq 1) then begin
            print, 'Continue with galaxy? 0=no 1=yes'
            s = get_kbrd(1)
        endif else s = 1

        ;********************************************************
        ; ALL MODES 
        ;********************************************************

        if(s eq 1) then begin 
         
            ;******************
            ; get galaxy skybox
            ;******************

            xskybox = fltarr(4)
	    boxsize = skyboxsize
            xskybox = findskybox(boxsize, gal_seg, sm_img, 5)
            if (xskybox[1] eq 0) then begin
	              s=0
                      interactive=0
	    endif

            G.skybox=[xskybox[0], xskybox[1], xskybox[2], xskybox[3]]
            skyvector= sm_img[xskybox[0]:xskybox[1], xskybox[2]:xskybox[3]]
            sky_value = avg(skyvector)
            sky_sig = robust_sigma(skyvector)
 
            if (sky_value gt 0.0) then begin
                G.bkgnd= sky_value
            endif else begin
                G.bkgnd = 0.00
            endelse

            xcsky = boxsize/2 + xskybox[0]
            ycsky = boxsize/2 + xskybox[2]

        ;********************************************************
        ; start interactive mode 
        ;********************************************************

	    if (display eq 1) then begin
                boxsize2 = boxsize * imscale
                xcsky2 = xcsky * imscale2
                ycsky2 = ycsky * imscale2
            	tvbox, boxsize2, xcsky2, ycsky2, color=white
             endif
        ;********************************************************
        ; end interactive mode 
        ;********************************************************

            print, 'Sky value = ', sky_value, ' +/- ', sky_sig

                                ; interactive sky + segmap check

        ;********************************************************
        ; start interactive mode 
        ;********************************************************
            if (interactive eq 1) then begin
                print, 'Adopt measured sky value? 0=no 1=yes'
                in = get_kbrd(1)

                if (in eq 0) then G.bkgnd=0.0

                ;*************************
                ; check segmentation map
                ;*************************

                print, 'Examine segmentation map?  0=no 1=yes'
                in = get_kbrd(1)

                while in eq 1 do begin
                    tv, bytscl(gal_seg2, id[i]-500, id[i]+500 ), 1
                      
                    print, 'Galaxy seg id =  ', id[i]
                    print, 'Examine segmentation map'

                    in2 = 0
                    while in2 eq 0 do begin
                        print, 'Enter 1 to end, 0 to continue'
                        tvlist, gal_seg2, 5, 5, offset=[dw,0]
                        in2 = get_kbrd(1)
                    endwhile

                    print, 'Change Segmentation map ?  0=no 1=yes'
                    in = get_kbrd(1)
            
                    if in eq 1 then begin
                        read, bad_id, prompt=' Which seg id should I change to gal seg id? '
                        bad_idpix = where(gal_seg eq bad_id)
                        gal_seg(bad_idpix) = id[i]

                        tvscl, bytscl(gal_seg2, min_galseg, max_galseg), 1
                        print, " Undo change?  0=no 1=yes"
                        in3 = get_kbrd(1)

                        if in3 eq 1 then begin
                            gal_seg(bad_idpix) = bad_id 
                        endif
                    endif
                endwhile
            endif

	    if (display eq 1) then begin
            	loadct, color
            	tv, bytscl(alog10(sm_img2), alog10(disp_immin), alog10(disp_immax)), 0
            endif 

        ;********************************************************
        ; end interactive mode 
        ;********************************************************

            ;***********************************************
            ; mask background objects + replace badpixels
            ;***********************************************
            

            galid = id[i]
            badpix = where(gal_seg gt 0. and (gal_seg lt galid-0.5 OR gal_seg gt galid+0.5))
            gal_im = sm_img - G.bkgnd
            print, 'Masking ', N_ELEMENTS(badpix), ' pixels'
            print, id[i],  max(gal_seg), min(gal_seg)
            print, size(gal_seg)
            if (N_ELEMENTS(badpix) gt 1) then gal_im[badpix] = 0.0

            gal_im2 = frebin(gal_im, dw, dw)

        ;********************************************************
        ; start interactive mode 
        ;********************************************************
            if (display eq 1) then begin
                tv, bytscl(alog10(gal_im2), alog10(disp_immin), alog10(disp_immax)), 2
	    endif 

            ;************************************
            ; interactive check of masked image
            ;************************************

            if (interactive eq 1) then begin
                print, 'Masked image ok?  0=no 1=yes'
                in = get_kbrd(1)

                while in eq 0 do begin
                    mask_im = smooth(gal_im, 5)
                    if N_ELEMENTS(badpix) gt 1 then mask_im(badpix) = 0.0 

                    mask_im2 = frebin(mask_im, dw, dw)
                    tv, bytscl(alog10(mask_im2), alog10(disp_immin), alog10(disp_immax)), 0
                    print, 'Select bad pixel box'
                    curval, filename='tmpbadpix'
                    readcol, 'tmpbadpix', xbad, ybad, intens, format=fmt_sky, skipline=2
  
                    if xbad[1] lt xbad[0] then begin
                        xx = xbad[0]
                        xbad[0] = xbad[1]
                        xbad[1] = xx
                    endif

                    if ybad[1] lt ybad[0] then begin
                        yy = ybad[0]
                        ybad[0] = ybad[1]
                        ybad[1] = yy
                    endif

        
                    if( xbad[0] eq xbad[1] AND ybad[0] eq ybad[1]) then begin
                        print, 'No region masked'
                        file_delete, 'tmpbadpix'
                    endif else begin
                        xbad2 = long(round(float(xbad)/imscale2))
                        ybad2 = long(round(float(ybad)/imscale2))
                       ; print, imscale2, G.npix, xbad2, ybad2
                    endelse
 
                    if xbad2[0] lt 0 then xbad2[0] = 0.0
                    if ybad2[0] lt 0 then ybad2[0] = 0.0 
                    if xbad2[1] gt G.npix-1 then xbad2[1] = G.npix-1
                    if ybad2[1] gt G.npix-1 then ybad2[1] = G.npix-1

                    gal_im[xbad2[0]:xbad2[1], ybad2[0]:ybad2[1]] = 0.0
 
                    gal_im2 = frebin(gal_im, dw, dw)
                    tv, bytscl(alog10(gal_im2), alog10(disp_immin), alog10(disp_immax)), 2
                    
                    file_delete, 'tmpbadpix'

                    print, 'Masked image ok?  0=no 1=yes'
                    in = get_kbrd(1)
                endwhile

            endif

            ;*******************************************************
            ; interactively check inital x,y center and ellipticity 
            ;********************************************************

            if (display eq 1) then begin
            
                tv, bytscl(alog10(gal_im2), alog10(disp_immin), alog10(disp_immax)), 0

                !p.position=[0, 0, 1./3., 1.]
                !x.margin=[0,0]
                !y.margin=[0,0]
             	contour, gal_im2, xstyle=1, xrange=[0, dw], $
                	ystyle=1, yrange=[0, dw], /noerase, /nodata

            	xc1= [G.axc*imscale2]
            	yc1= [G.ayc*imscale2]

                loadct, 0
            	oplot, xc1, yc1, thick=3, psym=4, color=254
                xyouts, 10, 10, 'check center', color=254, charsize=1.5
            endif 

            if (interactive eq 1) then begin

                ;************************
                ;check center
                ;************************

                print, 'Center ok?  0=no 1=yes'
                in = get_kbrd(1)

                while in eq 0 do begin
                    print, 'Select new center'
                    curval, filename='tmpcenter'
                    readcol, 'tmpcenter', xc1, yc1, intens, format=fmt_sky, skipline=2
                   
                    oplot, xc1, yc1, thick=3, psym=7, color=255 
            
                    print, 'Center ok?  0=no 1=yes'
                    in = get_kbrd(1)
                    G.axc=xc1/imscale2
                    G.ayc=yc1/imscale2
                    G.mxc=xc1/imscale2
                    G.myc=yc1/imscale2
                    file_delete, 'tmpcenter'
                endwhile

                ;****************************
                ;check  ellipticity and PA
                ;****************************

                rmax = pet_rad_ellip(0.2, G, gal_im)   
                print, "R_pet_ellip = ", rmax, " a/b = ",  G.e, "  pa = ", G.pa 
                dist_ellipse, r_ellip, dw, G.axc*imscale2, G.ayc*imscale2, G.e, G.pa
                loadct, color
                tv, bytscl(alog10(gal_im2), alog10(disp_immin), alog10(disp_immax)), 0

                !p.position=[0, 0, 1./3., 1.]
                !x.margin=[0,0]
                !y.margin=[0,0]
                 contour, r_ellip, xstyle=1, xrange=[0, dw], $
                  ystyle=1, yrange=[0, dw], $
                  levels=[rmax*imscale2], c_colors=[255], thick=2, /noerase

                xyouts, 10, 10, 'check ellip/pa', color=254, charsize=1.5

                print, 'Ellip/pa ok?  0=no 1=yes'
                in = get_kbrd(1)

                while in eq 0 do begin
                    print, "old a/b = ", G.e, " old pa = ", G.pa
                    read, newe, PROMPT="New a/b? (between 1.0 and 4.0)"
                    read, newpa, PROMPT= "New pa? "
  
                    G.e = newe
                    G.pa = newpa

                    rmax = pet_rad_ellip(0.2, G, gal_im)   
                    print, "R_pet_ellip = ", rmax, " a/b = ",  G.e, "  pa = ", G.pa   
                    dist_ellipse, r_ellip, dw, G.axc*imscale2, G.ayc*imscale2, G.e, G.pa
                    tv, bytscl(alog10(gal_im2), alog10(disp_immin), alog10(disp_immax)), 0

                    !p.multi=[0, 3, 1]
                    contour, r_ellip, xstyle=1, xrange=[0, dw], $
                      ystyle=1, yrange=[0, dw], $
                      levels=[rmax*imscale2], c_colors=[255], thick=2, /noerase


                    print, 'Ellip/pa ok?  0=no 1=yes'
                    in = get_kbrd(1)
                
                endwhile
   
                print, "e = ", G.e, "pa = ", G.pa 
            
                print, 'Continue with galaxy? 0=no 1=yes'
                s = get_kbrd(1)

                ;***************************************************
                ; do visual classifcation for interactive mode
                ;***************************************************
                print, "Type 0=e/so 1=spiral 2=edge-on spiral 3=irr 4=merger 5=star 6=? "
                read, type, PROMPT="type? " 

            endif else s = 1
        if (xskybox[1] lt 1) then s=0 ; skip to next galaxy if no skybox

        endif 

        ;********************************************************
        ; end interactive mode 
        ;********************************************************

        ;**************************************************
        ; measure galaxy morphologies
        ;**************************************************
        if(s eq 1) then begin 

            ;*************************************
            ; write galaxy postage stamps to fits
            ;*************************************
           
        ;********************************************************
        ; start interactive mode 
        ;********************************************************
            if (display eq 1) then begin
                tv, bytscl(alog10(sm_img), alog10(disp_immin), alog10(disp_immax)), 0
            endif 
        ;********************************************************
        ; end interactive mode 
        ;********************************************************
            

            fxhmake, hd1, gal_im
            fxwrite, galfile, hd1, gal_im

            fxhmake, hd2, gal_wht
            fxwrite, galwhtfile, hd2, gal_wht

            fxhmake, hd3, gal_exp
            fxwrite, galexpfile, hd3, gal_exp
            
            fxhmake, hd3, gal_seg
            fxwrite, galseg1file, hd3, gal_seg

            ;******************************************
            ; run dogalaxy.pro, main morphology routine
            ;********************************************* 
            ;xx = fltarr(24)
            xx = dogalaxy_mos(G)
                                ;xx = [sn, rchalf, rehalf,
                                ;rcpet,repet, ax, ay, mx, my, c, r20,
                                ;r80, a, s, g, m20, flag, isoflux

                                ;xx =[sn, r_half_c,  r_half_e,  r_cir,
                                ;r_ellip, G.axc, G.ayc, G.mxc, G.myc,
                                ;cc, a[0], s, gg[0], alog10(mhi),
                                ;flagseg, 
                                ;n_elements(galmap),M,I,D,flux_pet_ell,a1,a2,nseg]

            out[5:22] = xx[0:17]  ;selects [sn, r_half_c,  r_half_e,  r_cir,  r_ellip, G.axc, G.ayc, G.mxc, G.myc, cc, a[0], s, gg[0], alog10(mhi), flagseg, n_elements(galmap)]

            ;*************************************
            ; get mag and surface brightnesses
            ;*************************************

            out[22] = out[22]
            flux = out[22]
            rmax = out[9]

            if(flux ne -100.0 and xx[0] ne -99) then begin
                newmag = -2.5*alog10(flux) + zeropt

                ;gal_im = gal_im/G.exptime

                mu_pet = getmu_pet(G, gal_im, rmax)

                if (mu_pet gt -99) then begin
                    mu_pet1 = -2.5*alog10(mu_pet/ G.scale/ G.scale) + zeropt
                endif else begin
                    mu_pet1 = mu_pet
                endelse
            
                
                mu_apet = getmu_apet(G, gal_im, rmax)
                if (mu_apet gt -99) then begin
                    mu_apet1 = -2.5*alog10(mu_apet/ G.scale/ G.scale) + zeropt
                endif else begin
                    mu_apet1 = mu_apet
                endelse


                mu_iso = getmu(gal_im, gal_seg, id[i])
                if (mu_iso gt -99) then begin
                    mu_iso1 = -2.5*alog10(mu_iso/ G.scale / G.scale) + zeropt
                endif else begin
                    mu_iso1 = mu_iso
                endelse

           ; write output
            endif else begin
                ;mag = -99.0
                mu_iso1 = -99.0
                mu_pet1 = -99.0
                mu_apet1 = -99.0
                newmag = -99.0
            endelse

          
            out[23] =  type
            out[24] = newmag
            out[25] = mu_iso1
            out[26] = mu_pet1
            out[27] = mu_apet1

            out[28] = xx[18] ;M, stat
            out[29] = xx[19] ;I, stat
            out[30] = xx[20] ;D, stat
            out[31] = xx[21] ;flux_pet_ell

            out[32] = xx[22] ;a1
            out[33] = xx[23] ;a2
            out[34] = xx[24] ;nseg from gen_segmap()
 	    
	    out[35] = xx[25] ;level
	    out[36] = xx[26] ;xpeak, from I_statistic()
	    out[37] = xx[27] ;ypeak, from I_statistic()
	    out[38] = xx[28] ;xcenter, from D_statistic()
	    out[39] = xx[29] ;ycenter, from D_statistic()
	    out[40] = xx[30] ;D', D/r_pet_ell
	    out[41] = xx[31] ;M', M without additional A(1)
          
            ; convert pixels to arcsec for radii
            if out[6] ne -99 then out[6] = out[6] * G.scale
            if out[6] ne -99 then out[7] = out[7] * G.scale
            if out[6] ne -99 then out[8] = out[8] * G.scale
            if out[6] ne -99 then out[9] = out[9] * G.scale
 
          ;*******************************************************************
          ; write output,  clean up files
          ;*******************************************************************

           ;Turn Nan and Inf's -> -99.0
            for out_num=0, n_elements(out)-1 do begin
               if (finite(out[out_num]) eq 0) then out[out_num] = -99.0
            endfor

            printf, 3, out, format= fmt_out

           ; delete files
            file_delete, galfile, /allow_nonexistent
            file_delete, galwhtfile, /allow_nonexistent
            file_delete, galsegfile, /allow_nonexistent
            file_delete, galseg1file, /allow_nonexistent
	    file_delete, galexpfile, /allow_nonexistent



            if(interactive eq 1) then begin
                print, 'Next galaxy?  0=no 1=yes'
                in = get_kbrd(1)
 
                if (in eq 0) then begin
                    print, 'Redo this galaxy?  0=no 1=yes'
                    in = get_kbrd(1)
                    if (in eq 1) then i=i-1 else i=n
                endif
            endif


        endif  else begin       ; close if don't skip gala
          
            ;***************************************************
            ; loop through to next galaxy
            ;*************************************************

            if(interactive eq 1) then begin
 
                print, 'Next galaxy?  0=no 1=yes'
                in = get_kbrd(1)
 
                if (in eq 0) then begin
                  print, 'Redo this galaxy?  0=no 1=yes'
                  in = get_kbrd(1)
                  if (in eq 1) then i=i-1 else i=n
              endif

          endif

      endelse

  endelse ; close if galaxy not near edge
  i = i+1

endwhile ; close main galaxy loop

close, 3 ; close output file
      
end
