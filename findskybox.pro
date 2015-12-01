FUNCTION FINDSKYBOX,  boxsize, segmap, img, minxy

  dimen = size(img, /dimensions)
  n = dimen[0]

  ii = dindgen(n*n) 
  ix = long(ii mod n )
  iy = long(ii/ n)  
 
  skypixels = where(segmap eq 0 AND ix gt minxy AND iy gt minxy AND $
                      ix lt (n-minxy) AND iy lt (n-minxy), npix)

  if (skypixels[0] eq -1) then print, 'no skypixels'
  ix_sky = ix(skypixels)
  iy_sky = iy(skypixels)
  v = sort(ix_sky)

  ;print, ix_sky[v[0]], iy_sky[v[0]]
  skybox = [0.0, 0.0, 0.0, 0.0]
  ;print, npix

  i= 0
  while i lt npix-1 do begin
    xmin = ix_sky(v[i])
    ymin = iy_sky(v[i])
    xmax = xmin + boxsize
    ymax = ymin + boxsize
    ;print, n, boxsize, max(ix), max(iy), xmin, xmax, ymin, ymax

    if (xmax ge n-minxy) OR (ymax ge n-minxy) AND (boxsize gt 10) then begin
        i = 0
        boxsize = boxsize-2.0
    endif  else begin
	if (boxsize lt 11) then begin
	  i= npix
	endif else begin
        	badsky = where( segmap[xmin:xmax,ymin:ymax] ne 0)
        	zerosky = where( img[xmin:xmax,ymin:ymax] eq 0.0000000)
        	fraczero = float(N_ELEMENTS(zerosky))/float(boxsize*boxsize)

        	if ( (badsky[0] eq -1) AND (fraczero lt 0.1) ) then begin
            	skybox =[ xmin, xmax, ymin, ymax]    
            	i = npix
        	endif else print, "Bad sky pixels ..."
	endelse

    endelse
    i = i+1
  endwhile

    print, 'Skyboxsize = ', boxsize, ' Box is ', skybox


 return, skybox
end

