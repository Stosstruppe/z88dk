POS	equ	$cf00

	org	$d000

mask:	db	$01,$10,$02,$20,$04,$40,$08,$80

sintbl:	db	5,12,18,24,30,37,43,49
	db	55,61,67,73,79,85,91,97
	db	103,108,114,120,125,131,136,141
	db	146,151,156,161,166,171,176,180
	db	184,189,193,197,201,205,208,212
	db	215,219,222,225,228,230,233,236
	db	238,240,242,244,246,247,249,250
	db	251,252,253,254,254,255,255,255

	;	$d048
	call	init
	ld	hl, frame
	ld	(hl), 0
.loop
	call	render
	ld	hl, frame
	inc	(hl)
	jp	loop

render:
	call	cls
	call	vertex_shader
	call	draw_elements
	ret

; vtx -> POS
vertex_shader:
	ld	a, (frame)
	call	sin
	ld	(fsin), de
	ld	a, (frame)
	add	a, 64
	call	sin
	ld	(fcos), de
	ld	hl, vtx
	ld	ix, POS
	ld	b, 8
vertex_loop:
	push	bc
	ld	de, x0
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	push	hl
				; model
	ld	hl, (y0)
	ld	de, -85		; y -= 1/3
	add	hl, de
	ld	(y1), hl
				; x = x*c + z*s
	ld	bc, (x0)
	ld	de, (fcos)
	call	mul
	push	hl
	ld	bc, (z0)
	ld	de, (fsin)
	call	mul
	pop	de
	add	hl, de
	ld	(x1), hl
				; z = z*c - x*s
	ld	bc, (x0)
	ld	de, (fsin)
	call	mul
	push	hl
	ld	bc, (z0)
	ld	de, (fcos)
	call	mul
	pop	de
	or	a
	sbc	hl, de
;	ld	(z1), hl
				; projection
;	ld	hl, (z1)
	ld	de, $0600	; z += dist
	add	hl, de
	ex	de, hl

	ld	hl, (x1)
	push	de
	call	div
	ld	a, 80
	add	a, l
	ld	(ix+0), a
	inc	ix

	ld	hl, (y1)
	pop	de
	call	div
	ld	a, 50
	sub	l
	ld	(ix+0), a
	inc	ix

	pop	hl
	pop	bc
	djnz	vertex_loop
	ret

draw_elements:
	ld	ix, idx
	ld	b, 12
draw_loop:
	push	bc
	ld	a, (ix+0)
	inc	ix
	add	a, a
	ld	h, POS/256
	ld	l, a
	ld	e, (hl)
	inc	l
	ld	d, (hl)
	push	de

	ld	a, (ix+0)
	inc	ix
	add	a, a
	ld	h, POS/256
	ld	l, a
	ld	e, (hl)
	inc	l
	ld	d, (hl)
	pop	hl
	call	line
	pop	bc
	djnz	draw_loop
	ret

; hl = (bc*de)>>8
mul:
	ld	a, b
	xor	d
	push	af		; sign flag
	bit	7, b		; abs bc
	jr	z, mulnbc
	sub	a
	sub	c
	ld	c, a
	sbc	a, a
	sub	b
	ld	b, a
mulnbc:
	bit	7, d		; abs de
	jr	z, mulnde
	sub	a
	sub	e
	ld	e, a
	sbc	a, a
	sub	d
	ld	d, a
mulnde:
	ld	hl, 0
	sla	e
	rl	d
	jr	nc, mul1st
	ld	h, b
	ld	l, c
mul1st:
	ld	a, 15
mulloop:
	add	hl, hl
	rl	e
	rl	d
	jr	nc, mulnext
	add	hl, bc
	jr	nc, mulnext
	inc	de
mulnext:
	dec	a
	jp	nz, mulloop
	ld	l, h		; hl = dehl>>8
	ld	h, e
	pop	af
	ret	p
	sub	a
	sub	l
	ld	l, a
	sbc	a, a
	sub	h
	ld	h, a
	ret

; hl = (hl*256) / de
; use: af bc de hl
div:
	bit	7, h
	push	af
	jr	z, div1
	sub	a
	sub	l
	ld	l, a
	sbc	a, a
	sub	h
	ld	h, a
div1:
	ld	c, 0
	ld	a, l
	ld	l, h
	ld	h, c
	ld	b, 16
div10:
	sla	c
	rla
	adc	hl, hl
	sbc	hl, de
	inc	c
	jr	c, div21
div11:
	djnz	div10
	jp	div2
div20:
	sla	c
	rla
	adc	hl, hl
	add	hl, de
	dec	c
	jr	c, div11
div21:
	djnz	div20
	dec	c
div2:
	ld	h, a
	ld	l, c
	pop	af
	ret	z
	sub	a
	sub	l
	ld	l, a
	sbc	a, a
	sub	h
	ld	h, a
	ret

; de = sin(a)
; use: af de hl
sin:
	cp	128
	jr	nc, sin4
sin1:
	or	a
	jr	nz, sin2
	ld	de, 0
	ret
sin2:
	cp	64
	jr	c, sin3		; if (x > 63)
	ld	l, a		; x = 128 - x
	ld	a, 128
	sub	l
sin3:
	ld	l, a
	ld	h, 0
	ld	de, sintbl-1
	add	hl, de
	ld	e, (hl)
	ld	d, 0
	inc	e
	ret	nz
	inc	d
	ret
sin4:				; if (x > 127)
	sub	128		; x -= 128
	call	sin1
	sub	a		; y = -y
	sub	e
	ld	e, a
	sbc	a, a
	sub	d
	ld	d, a
	ret

; hl: y0 x0
; de: y1 x1
; bc: dy dx
line:
	ld	a, d		; abs(y1 - y0)
	sub	h
	jr	nc, line1
	neg
line1:
	ld	b, a
	ld	a, e		; abs(x1 - x0)
	sub	l
	jr	nc, line2
	neg
line2:
	cp	b
	ld	bc, $4d44	; ld b,h / ld c,l
	jr	nc, line3	; abs(x1 - x0) < abs(y1 - y0)
	ld	a, l		; swap(x0, y0)
	ld	l, h
	ld	h, a
	ld	a, e		; swap(x1, y1)
	ld	e, d
	ld	d, a
	ld	bc, $4c45	; ld b,l / ld c,h
line3:
	ld	(line_steep), bc

	ld	a, e
	cp	l
	jr	nc, line4	; x0 > x1
	ex	de, hl		; swap(xy0, xy1)
line4:
	ld	a, d		; dy = abs(y1 - y0)
	sub	h
	ld	c, $24		; inc h
	jr	nc, line5
	neg
	ld	c, $25		; dec h
line5:
	ld	b, a
	ld	a, c
	ld	(line_sy), a
	ld	a, e		; dx = x1 - x0
	sub	l
	ld	c, a
;	ld	a, c		; err = dx / 2
	srl	a		; srl a / rra
	jp	line_loopentry
line_loop:
	inc	l		; x0++
line_loopentry:
	push	bc		; dy dx
	push	hl		; y0 x0
	ld	d, a		; err
line_steep:
	ld	b, h
	ld	c, l
	push	de
	call	pset
	pop	de
	pop	hl
	pop	bc
	ld	a, l		; if (x0 == x1) break
	cp	e		; x1
	ret	z
	ld	a, d
	add	a, b		; err += dy
	jr	c, line_dx
	cp	c
	jr	c, line_loop	; if (err >= dx)
line_dx:
	sub	c		; err -= dx
line_sy:
	inc	h		; y0 += sy
	jp	line_loop

; c: x 0-159
; b: y 0-99
; xh=x/2 xl=x%2
; yh=y/4 yl=y%4
; addr = $f300 + yh*120 + xh
pset:
	ld	a, b
	rra
	and	$3e
	add	a, $75
	ld	l, a
	ld	h, $06		; hl = $0675 + yh*2
	ld	e, (hl)
	inc	l
	ld	d, (hl)		; de = $f300 + yh*120
	ld	a, c
	rra			; srl a
	add	a, e
	ld	e, a
	jr	nc, pset1
	inc	d
.pset1
	ld	a, (vram+1)
	sub	$f3
	add	a, d
	ld	d, a

	ld	a, b
	rrc	c
	rla
	and	$07		; yyx
	ld	l, a
	ld	h, mask/256
	ld	a, (hl)
	ex	de, hl
	or	(hl)
	ld	(hl), a
	ret

cls:
	ld	hl, (vram)
	ld	c, $64
	out	(c), l
	out	(c), h
	ld	a, h
	xor	$30		; $f3 / $c3
	ld	(vram+1), a

	ld	ix, 0
	add	ix, sp
	ld	hl, (vram)
	ld	de, 120*24-40
	add	hl, de
	ld	b, 24
cls_loop:
	ld	sp, hl
	ld	de, 0

	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de

	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de

	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de

	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de
	push	de

	ld	de, -120
	add	hl, de
	djnz	cls_loop
	ld	sp, ix
	ret

init:
	ld	hl, color
	call	$0951		; color
	ld	bc, 80*256+25
	call	$093a		; width
	ld	hl, $f300
	ld	(vram), hl
	ld	de, $c300
	ld	bc, 120*25
	ldir
	ret
.color	db	"0,0,1", 0

vtx:	dw	0,0,0, $100,0,0, $100,$100,0, 0,$100,0
	dw	0,0,$100, $100,0,$100, $100,$100,$100, 0,$100,$100

idx:	db	0,1, 1,2, 2,3, 3,0
	db	4,5, 5,6, 6,7, 7,4
	db	0,4, 1,5, 2,6, 3,7

vram:	ds	2
frame:	ds	1
fsin:	ds	2
fcos:	ds	2
x0:	ds	2
y0:	ds	2
z0:	ds	2
x1:	ds	2
y1:	ds	2
z1:	ds	2
