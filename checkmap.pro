FUNCTION CHECKMAP,  MAP, XC, YC

; this function checks to see if the segmap is contiguous
; if not, flag = 1

   region = search2d(map, xc, yc, 9.9, 10.1,  /diagonal)

   segmap = where(map eq 10.0, nmap)

   if (N_ELEMENTS(region) ne nmap) then flag = 1 else flag = 0

return, flag
end

