/*
zcc +pc88 circle6.c -create-app -subtype=disk
*/
#include <stdlib.h>

void circle(int cx, int cy, int ca, int color);

#asm
; de=x hl=y
pset:
			; x & 7
	ld	a, e
	and	7
			; y * 80
	ld	b, h
	ld	c, l
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
			; x >> 3
	srl	d
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e
	add	hl, de
	ld	de, 0xc000
	add	hl, de
			; 0x80 >> (x & 7)
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

_circle:
	ld	hl, 2
	add	hl, sp
	ld	de, color_
	ld	bc, 8
	ldir
	ld	a, (color_)
	out	($34), a
			; err = 0;
			; px = 0;
	ld	hl, 0
	ld	(err_), hl
	ld	(px_), hl
			; py = ca / 2;
	ld	hl, (ca_)
	srl	h
	rr	l
	ld	(py_), hl
circle_loop:
			; while (px <= ca && py >= 0) {
	ld	hl, (ca_)
	ld	de, (px_)
	or	a
	sbc	hl, de
	ret	c
	ld	hl, (py_)
	bit	7, h
	ret	nz
			; pset(cx + px, cy + py);
	ld	hl, (cx_)
	ld	bc, (px_)
	add	hl, bc
	ex	de, hl
	ld	hl, (cy_)
	ld	bc, (py_)
	add	hl, bc
	call	pset
			; pset(cx + px, cy - py);
	ld	hl, (cx_)
	ld	bc, (px_)
	add	hl, bc
	ex	de, hl
	ld	hl, (cy_)
	ld	bc, (py_)
	or	a
	sbc	hl, bc
	call	pset
			; pset(cx - px, cy - py);
	ld	hl, (cx_)
	ld	bc, (px_)
	or	a
	sbc	hl, bc
	ex	de, hl
	ld	hl, (cy_)
	ld	bc, (py_)
	or	a
	sbc	hl, bc
	call	pset
			; pset(cx - px, cy + py);
	ld	hl, (cx_)
	ld	bc, (px_)
	or	a
	sbc	hl, bc
	ex	de, hl
	ld	hl, (cy_)
	ld	bc, (py_)
	add	hl, bc
	call	pset
			; ex = (2 * px + 1);
	ld	hl, (px_)
	add	hl, hl
	inc	hl
	ld	(ex_), hl
			; ey = (-2 * py + 1) * 4;
	ld	hl, 0
	ld	de, (py_)
	or	a
	sbc	hl, de
	add	hl, hl
	inc	hl
	add	hl, hl
	add	hl, hl
	ld	(ey_), hl
			; err += ex + ey;
	ld	hl, (err_)
	ld	de, (ex_)
	add	hl, de
	ld	de, (ey_)
	add	hl, de
	ld	(err_), hl
			; if (err < 0) {
	bit	7, h
	jr	z, circle_errplus
			; px++;
	ld	hl, (px_)
	inc	hl
	ld	(px_), hl
			; e1 = err - ey;
	ld	hl, (err_)
	ld	de, (ey_)
	or	a
	sbc	hl, de
	ex	de, hl	; de=e1
			; if (err + e1 < 0) {
	ld	hl, (err_)
	add	hl, de
	bit	7, h
	jr	z, circle1
			; err = e1;
	ld	(err_), de
	jp	circle_loop
circle1:
			; py--;
	ld	hl, (py_)
	dec	hl
	ld	(py_), hl
	jp	circle_loop
circle_errplus:
			; py--;
	ld	hl, (py_)
	dec	hl
	ld	(py_), hl
			; e3 = err - ex;
	ld	hl, (err_)
	ld	de, (ex_)
	or	a
	sbc	hl, de
	ex	de, hl	; de=e3
			; if (err + e3 < 0) {
	ld	hl, (err_)
	add	hl, de
	bit	7, h
	jr	z, circle2
			; px++;
	ld	hl, (px_)
	inc	hl
	ld	(px_), hl
	jp	circle_loop
circle2:
			; err = e3;
	ld	(err_), de
	jp	circle_loop

color_:	ds	2
ca_:	ds	2
cy_:	ds	2
cx_:	ds	2

px_:	ds	2
py_:	ds	2
err_:	ds	2
ex_:	ds	2
ey_:	ds	2
#endasm

void main(void)
{
	asm("di");
	outp(0x32, 0xe9);	// ALU
	outp(0x35, 0x80);	// gvram

	for (int i = 0; i < 200; i += 3) {
		circle(320, 100, i, i%7 + 1);
	}

	outp(0x32, 0xa9);
	asm("ei");
}
