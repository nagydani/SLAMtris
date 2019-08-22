levels:	include	"levels/lvloffs.asm"

lvlset:	ld	(level),a
	ld	b,a
	add	a,a
	add	a,b
	ld	c,a
	ld	b,0
	ld	hl,levels
	add	hl,bc
	push	hl		; map index
	ld	a,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	cp	(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	jr	z,lvlsame
	res	6,b
lvlsame:and	a
	sbc	hl,bc
	ld	c,l
	ld	b,h		; BC = compressed length
	ld	hl,$FE00	; HL = end address
	sbc	hl,bc		; HL = start address
	ex	de,hl		; DE = start address
	pop	hl		; HL = map index
	ld	a,(hl)
	ex	af,af'		; A' = page
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	push	de

lvlcpl:	push	bc
	ld	bc,$7FFD
	ex	af,af'
	ld	(bank_m),a
	out	(c),a
	ex	af,af'
	ld	a,(hl)
	ex	af,af'
	push	af
	ld	a,$10
	out	(c),a
	pop	af
	ex	af,af'
	ld	(de),a
	inc	de
	inc	l
	jr	nz,lvlcp1
	push	hl
	push	de
	call	yield_main_to_track
	pop	de
	pop	hl
	inc	h
	jr	nz,lvlcp1
	ld	h,$C0
	ex	af,af'
	inc	a
	cp	$12
	jr	nz,np1
	inc	a
np1:	cp	$15
	jr	nz,np2
	inc	a
np2:	ex	af,af'

lvlcp1:	pop	bc
	dec	bc
	ld	a,b
	or	c
	jr	nz,lvlcpl

	ld	bc,$7FFD
	ld	a,$10
	ld	(bank_m),a
	out	(c),a
	pop	hl
	ld	de,$C000

	include "declzx56610.asm"
