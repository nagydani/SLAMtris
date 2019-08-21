; Read variable length quantity
; Input: HL = pointer to variable length quantity
; Output: NZ on error, BCDE = 32 bit integer, HL = pointer to after the quantity
; Pollutes: AF
varlen:	ld	bc,0
	ld	d,b
	ld	e,(hl)
	inc	hl
	bit	7,e
	ret	z
varlenl:ld	a,(hl)
	inc	hl
	rlca
	sra	b
	ret	nz
	ld	b,c
	ld	c,d
	ld	d,e
	rr	b
	rr	c
	rr	d
	rra
	ld	e,a
	jr	c,varlenl
	cp	a
	ret


mtrk:	defm	"MTrk"
	defb	0, 0

error1sp:
	pop	bc
	ret


; loop play
playmidi:
	ld	hl,playmidi
	push	hl
	ld	bc,2 * 50		; wait two seconds
	call	waitbc
	ld	hl,tune + $0E

; play midi track
; Input: HL = pointer to track
; Output: NZ on error
; Pollutes: DE, BC
track:	ld	de,mtrk
	ld	b,6
trackh:	ld	a,(de)
	inc	de
	cp	(hl)
	ret	nz
	inc	hl
	djnz	trackh
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ex	de,hl
	add	hl,de
	ex	de,hl
trackl:	and	a
	sbc	hl,de
	ret	z
	add	hl,de
	push	de
	call	varlen
	jr	nz,error1sp
	ld	a,b
	or	c
	or	d
	or	e
	push	hl
	call	nz,waitbcde	; to save CPU, only wait non-zero amounts
	pop	de
	ld	a,(de)
	add	a,a
	jr	nc,runst
	ld	(status),a
	inc	de
runst:	ld	a,(status)
	and	$E0
	ld	h,noteoff / $100
	ld	l,a
	call	jphl
	ex	de,hl
	pop	de
	jr	trackl

; wait BCDE ticks, yielding
; Pollutes: everything
waitbcde:
	ld	l,$90		; calculate number of frames for given tempo
waitl1:	ld	a,b
	or	a
	jr	nz,wait1
	ld	b,c
	ld	c,d
	ld	d,e
	ld	e,0
	ld	a,-8
	add	a,l
	ld	l,a
	jr	waitl1

wait1:	bit	7,b
	jr	nz,wait2
	sla	e
	rl	d
	rl	c
	rl	b
	dec	l
	jr	wait1

wait2:	res	7,b
	ld	a,l
	ld	hl,(stkend)
	ld	(hl),a
	inc	hl
	ld	(hl),b
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(stkend),hl
	ld	a,(delay)
	ld	b,a
	sra	b
	add	b		; * 1.5
	call	stack_a
	rst	$28
	defb	fmul
	defb	fend
	call	fp_to_bc	; wait BC frames
waitbc:	ld	de,(frames)
waitl2:	push	bc
	push	de
	call    yield_track_to_piano
	pop	de
	pop	bc
	ld	hl,(frames)
	and	a
	sbc	hl,de
	ld	a,h
	or	a
	ret	nz
	ld	a,l
	cp	c
	jr	c,waitl2
	ret

channels:	equ	6

piano:	ld	bc,$FFFD
	ld	l,b
	out	(c),l
	ld	de,$3807	; first PSG mixer, all notes ON, noise off
	call	outay
	ld	b,l
	dec	l
	out	(c),l
	ld	de,$3807	; second PSG mixer, all notes ON, noise off
	call	outay
	ld	hl,vols
	ld	de,vols + 1
	ld	bc,2 * channels - 1
	ld	(hl),0
	ldir
pianol:	ld	hl,vols
	ld	b,channels
pianol1:push	bc
	inc	b
	srl	b
	ld	a,$FF
	adc	a,a
	ld	e,a
	ld	a,11
	sub	a,b
	ld	bc,$FFFD
	out	(c),e		; select PSG
	out	(c),a
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	call	outayd
	ex	de,hl
	ld	bc,75		; decay * 256
	sbc	hl,bc
	jr	nc,loud
	ld	hl,0
loud:	ex	de,hl
	ld	(hl),d
	dec	hl
	ld	(hl),e
	inc	hl
	inc	hl
	pop	bc
	djnz	pianol1
nokeyp:	ld	de,(frames)
pianol2:push	de
	call	yield_piano_to_main
	call	c,note		; note played
	pop	de
	ld	hl,(frames)
	and	a
	sbc	hl,de
	jr	z,pianol2
	jr	pianol

; Play a note
note:	ld	hl,piano_flags
	bit	0,(hl)
	ret	nz
	sub	21		; note 21 is the lowest playable
	ret	c
	add	a,a
	ld	l,a
	ld	h,notes / $100
	ld	d,(hl)
	ld	a,(softest)
	dec	a
	jr	nz,note1
	ld	a,channels
note1:	ld	(softest),a
	inc	a
	rra
	ld	e,$ff
	rl	e
	ld	bc,$FFFD
	out	(c),e		; select PSG
	add	a,a
	xor	6
	ld	e,a
	call	outay
	inc	l
	ld	d,(hl)
	inc	e
	call	outay
	ld	a,(softest)
	add	a,a
	ld	e,a
	ld	d,0
	ld	hl,vols + channels * 2
	sbc	hl,de
	ld	(hl),$ff
	inc	hl
	ld	(hl),$0f
	ret

outay:	ld	bc,$FFFD
	out	(c),e
outayd:	ld	b,$BF
	out	(c),d
	ret

yield_track_to_piano:
	and	a		; clear CF, no data
send_track_to_piano:
	ld	(tracksp),sp
	ld	sp,(pianosp)
	ret

yield_piano_to_main:
	ld	(pianosp),sp
	ld	sp,(mainsp)
	ret

	include "align.asm"
noteoff:ld	a,(de)
	push	af
	inc	de
noff2:	; TODO faster attenuation
	pop	af
	inc	de
	ret
	defs	noteoff + $20 - $
noteon:	ld	a,(de)
	push	af
	inc	de
	ld	a,(de)
	or	a
	jr	z,noff2
	; TODO set volume
	pop	af
	push	de
	scf
	call	send_track_to_piano
	pop	de
	inc	de
	ret
	defs	noteon + $20 - $
keypr:	inc	de
	inc	de
	ret
	defs	keypr + $20 - $
contr:	inc	de
	inc	de
	ret
	defs	contr + $20 - $
progch:	inc	de
	ret
	defs	progch + $20 - $
chanpr:	inc	de
	ret
	defs	chanpr + $20 - $
pbend:	inc	de
	inc	de
	ret
	defs	pbend + $20 - $
sysex:	ex	de,hl
	ld	a,(status)
	cp	$FE
	jr	c,nometa
	inc	hl		; skip meta type
nometa:	call	varlen
	; TODO error handling
	add	hl,de
	ex	de,hl
	ret

softest:defb	channels
vols:	defs	2 * channels
status:	defb	0

	defs	100
pianostack:
	defw	piano
pianosp:defw	pianostack
	defs	100
trackstack:
	defw	playmidi
tracksp:defw	trackstack

piano_flags:
	defb	0	; bit 0 = mute
