j1:	or	(ix-12)
	or	(ix-1)
	or	(ix+0)
	or	(ix+1)
	ret	nz
	ld	c,1
dj1:	ld	(ix-12),c
	ld	(ix-1),c
	ld	(ix+0),c
	ld	(ix+1),c
	ret

z1:	or	(ix-12)
	or	(ix-11)
	or	(ix+0)
	or	(ix+1)
	ret	nz
	ld	c,2
dz1:	ld	(ix-12),c
	ld	(ix-11),c
	ld	(ix+0),c
	ld	(ix+1),c
	ret

t1:	or	(ix-11)
	or	(ix-1)
	or	(ix+0)
	or	(ix+1)
	ret	nz
	ld	c,3
dt1:	ld	(ix-11),c
	ld	(ix-1),c
	ld	(ix+0),c
	ld	(ix+1),c
	ret

s1:	or	(ix-10)
	or	(ix-11)
	or	(ix+0)
	or	(ix-1)
	ret	nz
	ld	c,4
ds1:	ld	(ix-10),c
	ld	(ix-11),c
	ld	(ix+0),c
	ld	(ix-1),c
	ret

i1:	or	(ix-1)
	or	(ix+0)
	or	(ix+1)
	or	(ix+2)
	ret	nz
	ld	c,5
di1:	ld	(ix-1),c
	ld	(ix+0),c
	ld	(ix+1),c
	ld	(ix+2),c
	ret

o1:	or	(ix-11)
	or	(ix-10)
	or	(ix+0)
	or	(ix+1)
	ret	nz
	ld	c,6
do1:	ld	(ix-11),c
	ld	(ix-10),c
	ld	(ix+0),c
	ld	(ix+1),c
	ret

l1:	or	(ix-10)
	or	(ix-1)
	or	(ix+0)
	or	(ix+1)
	ret	nz
	ld	c,7
dl1:	ld	(ix-10),c
	ld	(ix-1),c
	ld	(ix+0),c
	ld	(ix+1),c
	ret

i2:	or	(ix-11)
	or	(ix+0)
	or	(ix+11)
	or	(ix+22)
	ret	nz
	ld	c,5
di2:	ld	(ix-11),c
	ld	(ix+0),c
	ld	(ix+11),c
	ld	(ix+22),c
	ret

z2:	or	(ix-10)
	or	(ix+11)
	or	(ix+0)
	or	(ix+1)
	ret	nz
	ld	c,2
dz2:	ld	(ix-10),c
	ld	(ix+11),c
	ld	(ix+0),c
	ld	(ix+1),c
	ret

s2:	or	(ix-12)
	or	(ix+11)
	or	(ix+0)
	or	(ix-1)
	ret	nz
	ld	c,4
ds2:	ld	(ix-12),c
	ld	(ix+11),c
	ld	(ix+0),c
	ld	(ix-1),c
	ret

j2:	or	(ix-11)
	or	(ix+0)
	or	(ix+11)
	or	(ix+10)
	ret	nz
	ld	c,1
dj2:	ld	(ix-11),c
	ld	(ix+0),c
	ld	(ix+11),c
	ld	(ix+10),c
	ret

j3:	or	(ix+12)
	or	(ix-1)
	or	(ix+0)
	or	(ix+1)
	ret	nz
	ld	c,1
dj3:	ld	(ix+12),c
	ld	(ix-1),c
	ld	(ix+0),c
	ld	(ix+1),c
	ret

j4:	or	(ix-11)
	or	(ix+0)
	or	(ix+11)
	or	(ix-10)
	ret	nz
	ld	c,1
dj4:	ld	(ix-11),c
	ld	(ix+0),c
	ld	(ix+11),c
	ld	(ix-10),c
	ret

l2:	or	(ix-12)
	or	(ix-11)
	or	(ix+0)
	or	(ix+11)
	ret	nz
	ld	c,7
dl2:	ld	(ix-12),c
	ld	(ix-11),c
	ld	(ix+0),c
	ld	(ix+11),c
	ret

l3:	or	(ix+10)
	or	(ix-1)
	or	(ix+0)
	or	(ix+1)
	ret	nz
	ld	c,7
dl3:	ld	(ix+10),c
	ld	(ix-1),c
	ld	(ix+0),c
	ld	(ix+1),c
	ret

l4:	or	(ix+12)
	or	(ix-11)
	or	(ix+0)
	or	(ix+11)
	ret	nz
	ld	c,7
dl4:	ld	(ix+12),c
	ld	(ix-11),c
	ld	(ix+0),c
	ld	(ix+11),c
	ret

t2:	or	(ix-1)
	or	(ix-11)
	or	(ix+0)
	or	(ix+11)
	ret	nz
	ld	c,3
dt2:	ld	(ix-1),c
	ld	(ix-11),c
	ld	(ix+0),c
	ld	(ix+11),c
	ret

t3:	or	(ix+11)
	or	(ix-1)
	or	(ix+0)
	or	(ix+1)
	ret	nz
	ld	c,3
dt3:	ld	(ix+11),c
	ld	(ix-1),c
	ld	(ix+0),c
	ld	(ix+1),c
	ret

t4:	or	(ix+1)
	or	(ix-11)
	or	(ix+0)
	or	(ix+11)
	ret	nz
	ld	c,3
dt4:	ld	(ix+1),c
	ld	(ix-11),c
	ld	(ix+0),c
	ld	(ix+11),c
	ret

