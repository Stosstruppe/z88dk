	org	$d000

mask:	db	$01,$05,$25,$a5, $b5,$f5,$f7,$ff

	include	"norm.asm"

	;	$deae
	call	init

	ld	hl, norm
	ld	(pnorm), hl
	xor	a
Lout:
	ld	(sy), a		; for (sy = 0; sy < 100; sy += 4)
	xor	a
Lin:
	ld	(sx), a		; for (sx = 0; sx < 100; sx += 2)
	call	calc

	ld	a, (sx)
	add	a, 2
	cp	100
	jp	c, Lin

	ld	a, (sy)
	add	a, 4
	cp	100
	jp	c, Lout
L9:
	halt
	jp	L9

calc:
	ld	de, (pnorm)
	ld	hl, 3
	add	hl, de
	ld	(pnorm), hl	; pnorm += 3
	ex	de, hl
	ld	a, (hl)
	cp	$80
	ret	z

	ld	de, px
	ldi
	ldi
	ldi
	call	dot
	or	a
	jp	p, calc1	; if (z < 0) z = 0
	xor	a
calc1:
	cp	64
	jr	c, calc2	; if (z >= 64) z = 63
	ld	a, 63
calc2:
	rra
	rra
	rra
	and	$07
	ld	l, a
	call	sgput
	ret

dot:
	ld	a, (px)
	ld	l, 43
	call	mul8s
	ld	a, h
	ld	(tmp), a
	ld	a, (py)
	ld	l, -21
	call	mul8s
	ld	a, h
	ld	(tmp+1), a
	ld	a, (pz)
	ld	l, 43
	call	mul8s
	ld	a, h
	ld	hl, (tmp)
	add	a, h
	add	a, l
	ret

; hl = a * l
mul8s:
	ld	e, a
	ld	d, 80h
;	ld	a, e
	xor	d
	ld	e, a
				; 1st
	srl	l
	jr	c, mul1
	ld	a, d
mul1:
	srl	a
	rr	l
				; 2-7
	ld	b, 6
mul2:
	jr	nc, mul3
	add	a, e
	jp	mul4
mul3:
	add	a, d
mul4:
	rra
	rr	l
	djnz	mul2
				; final
	jr	nc, mul5
	ld	h, a
	ld	a, e
	cpl
	add	a, h
	jp	mul6
mul5:
	add	a, 7fh
mul6:
	rra
	rr	l
	add	a, 81h
	ld	h, a
				; hl <<= 2
	add	hl, hl
	add	hl, hl
	ret

sgput:
	push	hl

	ld	bc, (sx)
	ld	a, b
	rra
	and	$3e		; a = (sy/4)*2
	add	a, $75
	ld	l, a
	ld	h, $06		; hl = $0675 + a
	ld	e, (hl)
	inc	hl
	ld	d, (hl)		; de = $f300 + (sy/4)*120
	ld	h, 0
	ld	a, c
	add	a, 30
	rra
	ld	l, a
	add	hl, de		; hl = de + (sx+30)/2

	pop	de
	ld	d, mask/256
	ld	a, (de)
	ld	(hl), a
	ret

init:
	ld	bc, $0000
	call	$08f7		; function / color
	ld	hl, color
	call	$0951		; color
	ld	bc, 80*256+25
	call	$093a		; width
	ret
color:	db	"0,0,1", 0	; 低解像度グラフィック

sx:	ds	1	; screen 0..99
sy:	ds	1
px:	ds	1
py:	ds	1
pz:	ds	1
pnorm:	ds	2
tmp:	ds	2
