pro catalog_header, filen
printf, filen, '# 1 ID'
printf, filen, '# 2 RA'
printf, filen, '# 3 DEC'
printf, filen, '# 4 SEXMAG'
printf, filen, '# 5 MAGER'
printf, filen, '# 6 SN per pixel'
printf, filen, '# 7 R12_CIR'
printf, filen, '# 8 R12_ELL'
printf, filen, '# 9 RPET_CIR'
printf, filen, '# 10 RPET_ELL'
printf, filen, '# 11 AXC'
printf, filen, '# 12 AYC'
printf, filen, '# 13 MXC'
printf, filen, '# 14 MYC'
printf, filen, '# 15 C'
printf, filen, '# 16 R20'
printf, filen, '# 17 R80'
printf, filen, '# 18 A'
printf, filen, '# 19 S'
printf, filen, '# 20 G'
printf, filen, '# 21 M20'
printf, filen, '# 22 FLAG 0=good  1=bad segmap'
printf, filen, '# 23 NPIX'
printf, filen, '# 24 TYPE'
printf, filen, '# 25 MAG_ISO'
printf, filen, '# 26 MU_ISO'
printf, filen, '# 27 MU_PET'
printf, filen, '# 28 MU_APET'
printf, filen, '# 29 M'
printf, filen, '# 30 I'
printf, filen, '# 31 D'
printf, filen, '# 32 FLUX_PET_ELL'
printf, filen, '# 33 A1 Area of largest clump'
printf, filen, '# 34 A2 Area of second largest clump'
printf, filen, '# 35 NSEG number of pixels from gen_segmap()'
printf, filen, '# 36 LEVEL threshold used to calculate M'
printf, filen, '# 37 XPEAK '
printf, filen, '# 38 YPEAK'
printf, filen, '# 39 XCENTER'
printf, filen, '# 40 YCENTER'
printf, filen, '# 41 DPRIME D/RPET_ELL instead'
printf, filen, '# 42 MPRIME M without additional A(1)'
end

;level
;            out[36] == xx[26] ;xpeak, from I_statistic()
;            out[37] == xx[27] ;ypeak, from I_statistic()
;            out[38] == xx[28] ;xcenter, from D_statistic()
;            out[39] == xx[29] ;ycenter, from D_statistic()
;            out[40] == xx[40] ;D', D/r_pet_ell
;            out[41] == xx[41] ;M', M without additional A(1)
