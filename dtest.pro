xcen=0
ycen=0
n=5
tot=0
img=(randomn(seed,n,n)+2)*10

for jj=0, n-1 do begin
	for kk=0, n-1 do begin
		if (img[jj,kk] gt 0) then begin
			xcen= xcen+jj*img[jj,kk]
			ycen= ycen+kk*img[jj,kk]
			tot = tot+img[jj,kk]
			print, "xcen= ", xcen
			print, "ycen= ", ycen
			print, "tot= ", tot 
		endif
	endfor
endfor

xcen = xcen/tot
ycen = ycen/tot

print, xcen
print, ycen

print, img

end
