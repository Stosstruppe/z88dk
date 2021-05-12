	org	$d000

mask:	db	$01,$05,$25,$a5, $b5,$f5,$f7,$ff

	include	"norm.asm"
	include	"light.asm"

	;	$e1ae
	call	init
	ld	hl, frame
	ld	(hl), 0
loop:
	ld	hl, frame
	ld	a, (hl)
	inc	(hl)
	ld	l, a
	ld	h, 0
	ld	e, l
	ld	d, h
	add	hl, hl
	add	hl, de
	ld	de, light
	add	hl, de		; hl = light + a*3
	ld	de, vlight
	ldi
	ldi
	ldi
	call	draw
	jp	loop
L9:
	halt
	jp	L9

draw:
	ld	hl, norm
	ld	(pnorm), hl
	xor	a
draw1:
	ld	(sy), a		; for (sy = 0; sy < 100; sy += 4)
	xor	a
draw2:
	ld	(sx), a		; for (sx = 0; sx < 100; sx += 2)
	call	calc

	ld	a, (sx)
	add	a, 2
	cp	100
	jp	c, draw2

	ld	a, (sy)
	add	a, 4
	cp	100
	jp	c, draw1
	ret

calc:
	ld	de, (pnorm)
	ld	hl, 3
	add	hl, de
	ld	(pnorm), hl	; pnorm += 3
	ex	de, hl
	ld	a, (hl)
	cp	$80
	ret	z

	push	hl
	pop	ix
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
	ld	l, (ix)
	ld	a, (vlight)
	call	mul8s
	ld	a, h
	ld	(tmp), a
	ld	l, (ix+1)
	ld	a, (vlight+1)
	call	mul8s
	ld	a, h
	ld	(tmp+1), a
	ld	l, (ix+2)
	ld	a, (vlight+2)
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
vlight:	ds	3
frame:	ds	1
pnorm:	ds	2
tmp:	ds	2
