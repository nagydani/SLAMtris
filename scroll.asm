clr2ln:	call	clrln
clrln:	ld	b,$0A
clrlne:	xor	a
	cp	b
	jr	z,clrlnl0
clrlnl1:ld	(de),a
	inc	e
	djnz	clrlnl1
clrlnl0:set	5,d
	ld	a,($6000)
	ld	b,$0A
clrlnl2:dec	e
	ld	(de),a
	djnz	clrlnl2
	res	5,d
scroll:	ld	bc,$9F07
	ld	hl,(cupadd)
	inc	l
scrl:	push	bc
	ld	e,l
	ld	d,h
	inc	h
	ld	a,h
	and	c
	jr	z,pxdown
pxdownr:ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	dec	l
	dec	e
	set	5,h
	set	5,d
	ldd
	ldd
	ldd
	ldd
	ldd
	ldd
	ldd
	ldd
	ldd
	ldd
	inc	l
	inc	e
	res	5,h
	res	5,d
	pop	bc
	djnz	scrl
	ret
pxdown:	ld	a,l
	add	$20
	ld	l,a
	jr	c,pxdownr
	ld	a,h
	sub	$08
	ld	h,a
	push	hl
	push	de
	call	yield_main_to_track
	pop	de
	pop	hl
	jr	pxdownr

showctr:ld	b,16
	ld	hl,(cupadd)
	ld	de,$1770
	add	hl,de
	ex	de,hl
	ld	hl,ctrtext
showctl:push	bc
	push	hl
	call	clr2ln
	ld	a,8
	ld	bc,font - $100
prnctll:pop	hl
	ex	af,af'
	ld	ixl,$0A
	push	hl
prnctl:	ld	a,(hl)
	inc	hl
	cp	$0A
	jr	z,ctleol
	push	hl
	add	a,a
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,bc
	ldi
	inc	bc
	pop	hl
	defb	$DD
	dec	l; ixl
	jr	prnctl
ctleol:	push	bc
	ld	b,ixl
	push	hl
	call	clrlne
	pop	hl
	pop	bc
	inc	bc
	ex	af,af'
	dec	a
	jr	nz,prnctll
	pop	bc	; discard line pointer
	pop	bc
	djnz	showctl
	ret

ctrtext:incbin	"scroll.txt"
