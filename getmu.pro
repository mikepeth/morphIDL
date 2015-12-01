
FUNCTION getmu, img, map, id

  gal = where(map eq id, n)

  if (gal[0] ne -1) then begin
	  mu = total(img(gal))/ n
  endif else begin
	 mu = -99
  endelse

return, mu
end
