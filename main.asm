; System variables
bank_m:		equ	$5B5C
last_k:		equ	$5C08
repdel:		equ	$5C09
chars:		equ	$5C36
err_nr:		equ	$5C3A
flags:		equ	$5C3B
bordcr:		equ	$5C48
chans:		equ	$5C4F
stkend:		equ	$5C65
frames:		equ	$5C78
s_posn:		equ	$5C88
membot:		equ	$5C92

; ROM routines
pr_msg:		equ	$0C0A
chan_open:	equ	$1601
jphl:		equ	$162C
make_room:	equ	$1655
indexer:	equ	$16DC
stack_a:	equ	$2D28
fp_to_bc:	equ	$2DA2

; Calculator VM opcodes
fmul:		equ	$04
fend:		equ	$38

	org	$8200
	call	start
next:	ld	ix,cup + 16
	ld	hl,(cupadd)
	ld	(window),hl
	ld	hl,toprow
	ld	(top),hl
	ld	a,20
	ld	(height),a
	call	drawcup
	ld	a,3
	ld	(height),a
	ld	hl,(permptr)
rnd:	inc	l
	ld	a,7
	and	l
	ld	(permptr),a
	jr	nz,shuffle
	ld	l,a
	ld	e,l
	ld	d,h
	ld	bc,(frames)
shufl:	ld	a,e
	add	(hl)
	add	c
	and	7
	ld	e,a
	call	rswap
	inc	l
	ld	a,c
	rra
	rr	b
	rr	c
	ld	a,c
	rra
	rr	b
	rr	c
	ld	a,c
	rra
	rr	b
	rr	c
	ld	a,7
	and	l
	ld	l,a
	jr	nz,shufl
shuffle:ld	hl,(permptr)
	ld	a,(hl)
	or	a
	jr	z,rnd
	ex	af,af'
	ld	a,(nextbuf)
	ex	af,af'
	ld	(nextbuf),a
	ld	hl,bordcr
	add	a,(hl)
	ld	b,a
	ld	hl,$660E
nextl:	ld	(hl),b
	inc	l
	ld	(hl),b
	dec	h
	ld	(hl),b
	dec	l
	ld	(hl),b
	dec	h
	ld	a,h
	and	7
	jr	nz,nextl
	ld	a,b
	and	7
	dec	a
	add	a,a
	add	a,a
	ld	e,a
	ld	d,0
	ld	hl,nextt
	add	hl,de
	ld	de,$420E
	call	nextr
	inc	d
	inc	hl
	inc	hl
	call	nextr

	ex	af,af'
	dec	a
	add	a,a
	add	a,a
	add	a,a
	ld	hl,j1shape
	ld	e,a
	ld	d,0
	add	hl,de
	call	setshape
	call	shapeon
	jr	nz,gameover
dropl:	call	drawcup
	call	shapeoff
	ld	bc,(frames)
loopd:	push	bc
	ld	hl,flags
	bit	5,(hl)
	jr	z,nokey
	ld	c,(iy+last_k-err_nr)
	res	5,(hl)
	ld	hl,keytab
	call	indexer
	jr	nc,nokey
	ld	de,nokey
	push	de
	ld	e,(hl)
	ld	d,0
	add	hl,de
	jp	(hl)

gameover:
	call	shapeoff
	call	newgame
	jp	next

nokey:	call	yield_main_to_track
	pop	bc
	ld	hl,(frames)
	and	a
	sbc	hl,bc
	ld	a,h
	or	a
	jr	nz,loopdq
	ld	a,(delay)
	cp	l
	jr	nc,loopd
loopdq:	ld	hl,one
	call	addscore
	ld	bc,11
	add	ix,bc
	call	awin

	call	shapeon
	jr	z,dropl
hit:	ld	bc,-11
	add	ix,bc
	call	shapeon
	xor	a
	ex	af,af'
	ld	hl,bottom
	ld	e,l
	ld	d,h
	ld	b,20
rowl:	push	bc
	push	hl
	push	de
	ld	bc,10
	lddr
	pop	de
	pop	hl
	ld	b,10
coll:	ld	a,(hl)
	or	a
	jr	z,notfull
	dec	hl
	djnz	coll
	ex	af,af'
	inc	a
	ex	af,af'
nrow:	dec	hl
	pop	bc
	djnz	rowl
	ex	af,af'
	jp	z,next
	push	af
	ld	c,a
	add	a,a
	add	a,a
	add	a,c
	add	a,a
	add	a,c
	ld	c,a
	call	clrcup
	pop	af
	ld	e,a
	ld	hl,rows
	ld	a,(hl)
	add	a,e
	ld	(hl),a
	ld	a,e
	ld	h,combo / $100
	dec	a
	add	a,a
	add	a,a
	ld	l,a
	call	addscore
	ld	a,(rows)
	ld	hl,maxrows
	sub	a,(hl)
	jp	c,next
	ld	(rows),a
	ld	d,0
	ld	a,$10
fade:	ld	bc,$BF3B
	out	(c),a
	ld	b,$FF
	out	(c),d
	inc	a
	and	$3F
	jr	nz,fade
	ld	a,(level)
	inc	a
	cp	10
	jr	z,nextlv
	call	lvlset
	call	setbg
	call	sethdr
nextlv:	jp	next

notfull:dec	hl
	djnz	notfull
	push	hl
	ld	hl,-11
	add	hl,de
	ex	de,hl
	pop	hl
	jr	nrow

nextr:	ldi
	ldi
	dec	hl
	dec	e
	inc	d
	ldd
	ldd
	inc	hl
	inc	e
	inc	d
	ret

nextt:	defb	$03, $00
	defb	$03, $6C

	defb	$03, $60
	defb	$00, $6c

	defb	$00, $60
	defb	$03, $6C

	defb	$00, $6C
	defb	$03, $60

	defb	$00, $00
	defb	$1B, $6c

	defb	$03, $60
	defb	$03, $60

	defb	$00, $60
	defb	$1B, $60

keytab:	defb	"o"
	defb	left - $
	defb	"p"
	defb	right - $
	defb	" "
	defb	hard - $
	defb	"z"
	defb	ccl - $
	defb	"x"
	defb	clw - $
	defb	"b"
	defb	bgtoggle - $
	defb	"r"
	defb	pause - $
	defb	"m"
	defb	mute - $
	defb	0

hardl:	call	drawcup
	call	shapeoff
hard:	call	yield_main_to_track
	ld	a,(frames)
hardw:	cp	(iy+frames-err_nr)
	jr	z,hardw
	ld	hl,two
	call	addscore
	ld	bc,11
	add	ix,bc
	call	awin
	call	shapeon
	jr	z,hardl
	pop	bc
	jp	hit

left:	dec	ix
	call	shapeon
	jr	z,nohit
	inc	ix
	ret

right:	inc	ix
	call	shapeon
	jr	z,nohit
	dec	ix
	ret

pause:	call	pclear
	ld	hl,pauselogo
	ld	de,$4464
	ld	bc,(pauselogo2 - pauselogo)*$100 + 5
	call	loopr
pausel:	call	yield_main_to_track
	ld	hl,flags
	bit	5,(hl)
	jr	z,pausel
	res	5,(hl)
	call	pclear
redraw:	ld	de,(cupadd)
	ld	hl,toprow
	ld	bc,$0B14
	call	loopr
	jp	shapeoff

bgtoggle:
	call	shapeon
	ld	hl,background
	inc	(hl)
	jr	redraw

mute:	ld	hl,piano_flags
	inc	(hl)
	ret

pclear:	ld	de,$4442
	ld	b,20
pausel2:push	bc
	ld	bc,$1C01
	ld	hl,empty
	call	loopr
	pop	bc
	djnz	pausel2
	ret

lshape:	equ	$ + 1
ccl:	ld	hl,i2shape
	call	setshape
	call	shapeon
	jr	z,nohit		; TODO wallkick

rshape:	equ	$ + 1
clw:	ld	hl,i2shape
	call	setshape
	call	shapeon
	jr	z,nohit
	jr	ccl		; TODO wallkick

nohit:	push	bc
	call	drawcup
	call	shapeoff
	pop	bc
	ret

shapeon:xor	a
shape:	equ	$ + 1
	jp	i1

shapeoff:
	ld	c,0
dshape:	equ	$ + 1
	jp	di1

setshape:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(shape),de
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(dshape),de
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(lshape),de
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	(rshape),de
	ret

; adjust redrawing window
; Input: BC = 11
awin:	ld	hl,height
	ld	a,(hl)
	cp	5
	jr	nc,mwin
	inc	(hl)
	ret

mwin:	ld	hl,(top)
	ld	de,lastwin
	sbc	hl,de
	ret	nc
	add	hl,de
	add	hl,bc
	ld	(top),hl
	ld	hl,window
	ld	a,32
	add	(hl)
	ld	(hl),a
	ret	nc
	inc	hl
	ld	a,(hl)
	add	8
	ld	(hl),a
	ret

addscore:
	ld	a,$16
	rst	$10
	xor	a
	rst	$10
	ld	a,6
	rst	$10
	ld	de,score
	and	a
	ld	b,4
addl:	ld	a,(de)
	adc	a,(hl)
	daa
	ld	(de),a
	inc	hl
	inc	de
	djnz	addl
	ld	b,4
prl:	dec	de
	ld	a,(de)
	rrca
	rrca
	rrca
	rrca
	and	$0F
	add	"0"
	rst	$10
	ld	a,(de)
	and	$0F
	add	"0"
	rst	$10
	djnz	prl
	ret

drawcup:ld	hl,(top)
	ld	de,(window)
	ld	bc,(height)
; HL = array pointer, DE = screen address, C = height, B = width
loopr:	push	bc
	push	de
loopc:	ld	a,(hl)
	and	$07
	jr	nz,brick
	push	de
	ld	a,(background)
	rra
	jr	nc,loopp
	bit	3,(hl)
	jr	nz,loopp

loope:	xor	a
	ld	(de),a
	set	5,d
	ld	(de),a
	res	5,d
	inc	d
	ld	a,$07
	and	d
	jr	nz,loope1
	ld	a,$20
	add	a,e
	ld	e,a
	jr	c,loope
	ld	a,d
	sub	a,$08
	ld	d,a
	jr	loope

loope1:	cp	4
	jr	nz,loope
	jr	loopc0

loopp:	set	7,d
	ld	a,(de)
	res	7,d
	ld	(de),a
	set	5,d
	set	7,d
	ld	a,(de)
	res	7,d
	ld	(de),a
	res	5,d
	inc	d
	ld	a,$07
	and	d
	jr	nz,loopp1
	ld	a,$20
	add	a,e
	ld	e,a
	jr	c,loopp
	ld	a,d
	sub	a,$08
	ld	d,a
	jr	loopp

loopp1:	cp	4
	jr	nz,loopp
loopc0:	pop	de
loopc1:	inc	e
	inc	hl
	djnz	loopc
	push	hl
	call	yield_main_to_track
	pop	hl
	pop	de
	ld	a,e
	add	$20
	ld	e,a
	jr	nc,third
	ld	a,d
	add	$08
	ld	d,a
third:	pop	bc
	dec	c
	jr	nz,loopr
	ret

brick:	ex	de,hl
	set	5,h
	ld	(hl),a
	rlca
	rlca
	rlca
	or	(hl)
	inc	h
	ld	(hl),a
	inc	h
	ld	(hl),a
	inc	h
	ld	(hl),a
	inc	h
	ex	af,af'
	ld	a,$20
	add	a,l
	ld	l,a
	jr	c,brick1
	ld	a,h
	sub	a,$08
	ld	h,a
brick1:	ex	af,af'
	ld	(hl),a
	inc	h
	ld	(hl),a
	inc	h
	ld	(hl),a
	inc	h
	and	$38
	ld	(hl),a
	res	5,h
	ld	a,$FE
	ld	(hl),a
	dec	h
	ld	(hl),a
	dec	h
	ld	(hl),a
	dec	h
	ld	(hl),a
	ld	a,l
	sub	a,$20
	ld	l,a
	jr	c,brick2
	ld	a,8
	add	a,h
	ld	h,a
brick2:	ld	a,$FE
	dec	h
	ld	(hl),a
	dec	h
	ld	(hl),a
	dec	h
	ld	(hl),a
	dec	h
	ld	(hl),$01
	ex	de,hl
	jr	loopc1


start:	ld	hl,$030F
	ld	(repdel),hl
	ld	hl,font - $100
	ld	(chars),hl
	ld	de,(chans)
	ld	hl,$7800
	and	a
	sbc	hl,de
	jr	z,room_ok
	ex	de,hl
	ld	c,e
	ld	b,d
	call	make_room
	inc	de
	ld	(chans),de
room_ok:ld	a,2
	call	chan_open
	ld	a,2
	out	($FF),a
	ld	bc,$BF3B
	ld	a,$40
	out	(c),a
	ld	b,$FF
	ld	a,1
	out	(c),a
newgame:ld	a,20
	ld	(delay),a
	xor	a
	call	lvlset
	call	setbg
	ld	hl,delay
	ld	a,(hl)
	push	af
	ld	(hl),20
	call	showcrd
	pop	af
	ld	(delay),a
	call	sethdr
	ld	hl,score
	ld	(hl),0
	ld	de,score + 1
	ld	bc,4		; reset score and row counters
	ldir
	ld	hl,cup + 1
	ld	bc,$0A00
clrcup0:ld	(hl),c
	inc	hl
	djnz	clrcup0
	ld	bc,20 * 11
clrcup:	ld	hl,cup
	ld	de,cup + 11
	ldir
	ret

rswap:	ld	a,(hl)
	ex	af,af'
	ld	a,(de)
	ld	(hl),a
	ex	af,af'
	ld	(de),a
	ret

setbg:	ld	hl,$E000
	ld	a,(hl)
	and	$F8
	ld	(bordcr),a
	rrca
	rrca
	rrca
	and	7
	out	($FE),a
	ld	de,$6000
	ld	bc,$1800
	push	bc
	ldir
	ld	h,$C0
	ld	d,$40
	pop	bc
	ldir
	xor	a
palette:ld	bc,$BF3B
	out	(c),a
	ld	b,$FF
	ld	d,(hl)
	inc	hl
	out	(c),d
	inc	a
	and	$3F
	jr	nz,palette
header:	ret
	defb	$16, $00, $00
	defm	"SCORE:00000000  LEVEL"
	defb	$80 + ":"

sethdr:	ld	de,header
	xor	a
	call	pr_msg
	ld	de,lname
	xor	a
	call	pr_msg
fillhdr:ld	a,(s_posn)
	cp	1
	ret	z
	ld	a," "
	rst	$10
	jr	fillhdr

j1shape:defw	j1, dj1, j2shape, j4shape
z1shape:defw	z1, dz1, z2shape, z2shape
t1shape:defw	t1, dt1, t2shape, t4shape
s1shape:defw	s1, ds1, s2shape, s2shape
i1shape:defw	i1, di1, i2shape, i2shape
o1shape:defw	o1, do1, o1shape, o1shape
l1shape:defw	l1, dl1, l2shape, l4shape
i2shape:defw	i2, di2, i1shape, i1shape
z2shape:defw	z2, dz2, z1shape, z1shape
s2shape:defw	s2, ds2, s1shape, s1shape
j2shape:defw	j2, dj2, j3shape, j1shape
j3shape:defw	j3, dj3, j4shape, j2shape
j4shape:defw	j4, dj4, j1shape, j3shape
l2shape:defw	l2, dl2, l3shape, l1shape
l3shape:defw	l3, dl3, l4shape, l2shape
l4shape:defw	l4, dl4, l1shape, l3shape
t2shape:defw	t2, dt2, t3shape, t1shape
t3shape:defw	t3, dt3, t4shape, t2shape
t4shape:defw	t4, dt4, t1shape, t3shape

yield_main_to_track:
	ld	(mainsp),sp
	ld	sp,(tracksp)
	ret

mainsp:	defs	2

	include "shapes.asm"
	include	"midi.asm"
	include	"credits.asm"
	include	"levels.asm"

combo:	equ	$D900
one:	equ	$D910
two:	equ	$D914
delay:	equ	$D840
maxrows:equ	$D841
bank_n:	equ	$D842
cupadd: equ	$D844
lname:	equ	$D855

score:	defs	4
rows:	defb	0

window:	defs	2
top:	defw	toprow
height:	defb	3
width:	defb	11

cup:	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
toprow:	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
lastwin:defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
	defb	8,  0, 0, 0, 0, 0,  0, 0, 0, 0, 0
bottom:	equ	$ - 1
	defb	8,  8, 8, 8, 8, 8,  8, 8, 8, 8, 8

pauselogo:
	defb	2,2,2,7,8,8,6,6,6,4,4,4,4,4,8,8,5,8,8,8,8,3,8,8,8
pauselogo2:
	defb	2,8,8,7,8,8,6,8,6,4,8,4,8,4,8,8,5,8,8,8,8,8,8,8,8
	defb	2,2,2,7,8,8,6,6,6,4,8,4,8,4,5,5,5,5,5,1,1,3,8,2,2
	defb	8,8,2,7,8,8,6,8,6,4,8,4,8,4,8,8,5,8,8,1,8,3,8,2,8
	defb	2,2,2,7,7,7,6,8,6,4,8,4,8,4,8,8,5,8,8,1,8,3,2,2,8

nextbuf:defb	2
level:	defb	0
background:
	defb	0

font:	incbin	"slavic.bin"
tune:	incbin	"korobushka.mid"

	include	"align.asm"
	include "notes.asm"
empty:	defb	8,8,8,8,8,8,8
	defb	8,8,8,8,8,8,8
	defb	8,8,8,8,8,8,8
	defb	8,8,8,8,8,8,8
	include	"align.asm"
perm:	defb	0, 1, 2, 3, 4, 5, 6, 7
permptr:defw	perm + 7

