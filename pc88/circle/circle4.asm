; z80asm -b circle4.asm
; z88dk-appmake +pc88 -b circle4.bin --org 0xb000

	org	$b000

	ld	(svsp), sp
	ld	sp, $c000

	di
	ld	a, $e9	; ALU
	out	($32), a
	ld	a, $80	; VRAM
	out	($35), a

	ld	hl, 320
	ld	(cx_), hl
	ld	hl, 100
	ld	(cy_), hl
			; for (r = 5; r < 200; r += 5) {
	ld	hl, 5
;	ld	(r_), hl
	ld	a, l
main1:
	ld	(r_), a
			; color = (r & 7) + 1;
	and	7
	inc	a
	ld	(color_), a
	call	circle

	ld	a, (r_)
	add	a, 5
	cp	200
	jp	c, main1

	ld	a, $a9
	out	($32), a
	ei
	ld	sp, 0
svsp	equ	$ - 2
	rst	$38

circle:
	ld	a, (color_)
	out	($34), a
			; x = 0;
	ld	hl, 0
	ld	(x_), hl
			; y = r / 2;
	ld	hl, (r_)
	srl	h
	rr	l
	ld	(y_), hl
			; err = (4*y*y - 4*y + 2) - r*r;
	ld	bc, (r_)
	ld	de, (r_)
	call	mul
	push	hl	;[ r*r
	ld	hl, (y_)
	add	hl, hl
	add	hl, hl
	push	hl	;[[ 4*y
	ex	de, hl
	ld	bc, (y_)
	call	mul	; 4*y*y
	pop	de	;]]
	or	a
	sbc	hl, de
	inc	hl
	inc	hl	; (4*y*y - 4*y + 2)
	pop	de	;]
	or	a
	sbc	hl, de
	ld	(err_), hl
			; dx = 1;
	ld	hl, 1
	ld	(dx_), hl
			; dy = -8*y + 8;
	ld	bc, -8
	ld	de, (y_)
	call	mul
	ld	de, 8
	add	hl, de
	ld	(dy_), hl
circle1:
			; if (err > 0) {
	ld	hl, (err_)
	dec	hl
	bit	7, h
	jr	nz, circle2
			; err += dy;
	ld	hl, (err_)
	ld	de, (dy_)
	add	hl, de
	ld	(err_), hl
			; dy += 8;
	ld	hl, 8
	add	hl, de
	ld	(dy_), hl
			; y--;
	ld	hl, y_
	dec	(hl)
circle2:
	call	pset4
			; err += dx;
	ld	hl, (err_)
	ld	de, (dx_)
	add	hl, de
	ld	(err_), hl
			; dx += 2;
	inc	de
	inc	de
	ld	(dx_), de
			; x++;
	ld	hl, (x_)
	inc	hl
	ld	(x_), hl
	ex	de, hl
	ld	hl, (y_)
	add	hl, hl
	add	hl, hl
			; y * 4 - x >= 0;
;	or	a
	sbc	hl, de
	jp	nc, circle1
			; xlim = x - 1;
	ld	hl, (x_)
	dec	hl
	ld	(xlim_), hl
			; x = r;
	ld	hl, (r_)
	ld	(x_), hl
			; y = 0;
	ld	hl, 0
	ld	(y_), hl
			; err = (2*x*x - 2*x + 1) - 2*r*r;
			;     = 1 - 2*x;
	ld	hl, (x_)
	add	hl, hl
	ex	de, hl
	ld	hl, 1
	or	a
	sbc	hl, de
	ld	(err_), hl
			; dx = -4*x + 4;
			;    = (1 - x) * 4;
	ld	hl, 1
	ld	de, (x_)
	or	a
	sbc	hl, de
	add	hl, hl
	add	hl, hl
	ld	(dx_), hl
			; dy = 8;
	ld	hl, 8
	ld	(dy_), hl
circle11:
			; if (err > 0) {
	ld	hl, (err_)
	dec	hl
	bit	7, h
	jr	nz, circle12
			; err += dx;
	ld	hl, (err_)
	ld	de, (dx_)
	add	hl, de
	ld	(err_), hl
			; dx += 4;
	ld	hl, 4
	add	hl, de
	ld	(dx_), hl
			; x--;
	ld	hl, x_
	dec	(hl)
circle12:
			; if (x < xlim) break;
	ld	hl, (x_)
	ld	de, (xlim_)
	or	a
	sbc	hl, de
	jr	c, circle13

	call	pset4
			; err += dy;
	ld	hl, (err_)
	ld	de, (dy_)
	add	hl, de
	ld	(err_), hl
			; dy += 16;
	ld	hl, 16
	add	hl, de
	ld	(dy_), hl
			; y++;
	ld	hl, y_
	inc	(hl)
	jp	circle11
circle13:
	ret

; de:x hl:y
pset:
	ld	a, e	; a = x & 7
	and	$07

	ld	b, h	; hl = y * 80
	ld	c, l
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	srl	d	; de = x >> 3
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e
	add	hl, de
	ld	de, $c000
	add	hl, de

	ld	de, mask
	add	a, e
	ld	e, a
	jr	nc, pset1
	inc	d
pset1:
	ld	a, (de)
	ld	(hl), a
	ret

mask:	db	$80,$40,$20,$10, $08,$04,$02,$01

pset4:
			; pset(cx + x, cy + y);
	ld	hl, (cx_)
	ld	bc, (x_)
	add	hl, bc
	ex	de, hl
	ld	hl, (cy_)
	ld	bc, (y_)
	add	hl, bc
	call	pset
			; pset(cx + x, cy - y);
	ld	hl, (cx_)
	ld	bc, (x_)
	add	hl, bc
	ex	de, hl
	ld	hl, (cy_)
	ld	bc, (y_)
	or	a
	sbc	hl, bc
	call	pset
			; pset(cx - x, cy - y);
	ld	hl, (cx_)
	ld	bc, (x_)
	or	a
	sbc	hl, bc
	ex	de, hl
	ld	hl, (cy_)
	ld	bc, (y_)
	or	a
	sbc	hl, bc
	call	pset
			; pset(cx - x, cy + y);
	ld	hl, (cx_)
	ld	bc, (x_)
	or	a
	sbc	hl, bc
	ex	de, hl
	ld	hl, (cy_)
	ld	bc, (y_)
	add	hl, bc
	call	pset
	ret

; hl = bc * de
mul:
	ld	a, 16
mul1:
	add	hl, hl
	sla	e
	rl	d
	jr	nc, mul2
	add	hl, bc
mul2:
	dec	a
	jp	nz, mul1
	ret

cx_:	ds	2
cy_:	ds	2
r_:	ds	2
color_:	ds	1

x_:	ds	2
y_:	ds	2
xlim_:	ds	2
err_:	ds	2
dx_:	ds	2
dy_:	ds	2
