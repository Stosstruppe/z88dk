	org	$d000

	call	init

	ld	bc, 120
.loop
	ld	(xpos), bc
	call	vblank
	call	vblank
	call	vblank
	call	vblank
	call	scrl

	ld	hl, data
	ld	bc, (xpos)
	dec	c
	add	hl, bc
	ld	de, $f300+120*5
	ld	b, 11
.L1
	push	bc
	ld	a, (hl)
	ld	(de), a
	ld	bc, 120
	add	hl, bc
	ex	de, hl
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	L1

	ld	bc, (xpos)
	dec	c
	jp	nz, loop
.L99
	halt
	jp	L99

.xpos	ds	2

init:
	ld	hl, color
	call	$0951		; color
	ld	bc, 80*256+25
	call	$093a		; width
	ret

.color	db	"0,0,1", 0

scrl:
	ld	hl, $f300+120*5+78
	ld	de, $f300+120*5+79
	ld	b, 11
.scrl1
	push	bc
	ld	bc, 79
	lddr
	ld	bc, 120+79
	add	hl, bc
	ex	de, hl
	add	hl, bc
	ex	de, hl
	pop	bc
	djnz	scrl1
	ret

vblank:
.wait1
	in	a, ($40)
	and	$20
	jr	nz, wait1
.wait2
	in	a, ($40)
	and	$20
	jr	z, wait2
	ret

data:	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
	db	$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01,$ff,$f7,$f5,$b5,$a5,$25,$05,$01
