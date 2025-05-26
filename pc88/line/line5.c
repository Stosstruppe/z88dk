/*
zcc +pc88 line5.c -create-app -subtype=disk
*/

int line(int x0, int y0, int x1, int y1, int color);
#asm
_line:
				; args
	ld	hl, 2
	add	hl, sp
	ld	de, color_
	ld	bc, 10
	ldir
				; dx = abs(x1 - x0);
	ld	hl, (x1_)
	ld	de, (x0_)
	or	a
	sbc	hl, de
	call	abs
	ld	(dx_), hl
				; dy = abs(y1 - y0);
	ld	hl, (y1_)
	ld	de, (y0_)
	or	a
	sbc	hl, de
	call	abs
	ld	(dy_), hl
				; if (x0 > x1) {
	ld	hl, (x1_)
	ld	de, (x0_)
	or	a
	sbc	hl, de
	jr	nc, L1
				; swap(x0, x1);
	ld	hl, (x0_)
	ld	de, (x1_)
	ld	(x0_), de
	ld	(x1_), hl
				; swap(y0, y1);
	ld	hl, (y0_)
	ld	de, (y1_)
	ld	(y0_), de
	ld	(y1_), hl
L1:
				; ys = (y0 <= y1) ? 80 : -80;
	ld	hl, (y1_)
	ld	de, (y0_)
	or	a
	sbc	hl, de
	ld	hl, 80
	jr	nc, L2
	ld	hl, -80
L2:
	ld	(ys_), hl

	ld	bc, (x0_)
	ld	a, c
	and	7
				; addr = 0xc000 + y0 * 80 + (x0 >> 3);
	ld	hl, (y0_)
	ld	d, h
	ld	e, l
	add	hl, hl
	add	hl, hl
	add	hl, de		; x5
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl		; x80
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c
	add	hl, bc
	ld	de, $c000
	add	hl, de
				; mask = 0x80 >> (x0 & 7);
	ld	b, a
	inc	b
	ld	a, $01
L3:
	rrca
	djnz	L3

	di
	ld	e, a
	ld	a, $d9
	out	($32), a
	ld	a, $80
	out	($35), a
	ld	a, (color_)
	out	($34), a
	ld	a, e
				; if (dx > dy) {
	ex	de, hl
	ld	hl, (dy_)
	ld	bc, (dx_)
	or	a
	sbc	hl, bc
	ex	de, hl
	jr	nc, L4
	call	line_x
	jr	L5
L4:
	call	line_y
L5:
	ld	a, $a9
	out	($32), a
	ei
	ld	hl, 0
	ret

line_x:
	exx
	ld	de, (dy_)	; dy
	ld	hl, (dx_)
	ld	b, h		; dx
	ld	c, l
	srl	h		; err = dx / 2;
	rr	l
	exx
	ld	bc, (dx_)	; cnt = dx;
	inc	bc
lx1:
	ld	(hl), a		; *addr = mask;
				; step_x();
	rrca
	jr	nc, lx2
	inc	hl
lx2:
	exx
	or	a
	sbc	hl, de		; err -= dy;
	exx
	jr	nc, lx3		; if (err < 0) {
	exx
	add	hl, bc		; err += dx;
	exx
				; step_y();
	ld	de, (ys_)
	add	hl, de
lx3:
	dec	bc		; cnt--;
	ld	e, a
	ld	a, b
	or	c
	ld	a, e
	jp	nz, lx1
	ret

line_y:
	exx
	ld	de, (dx_)	; dx
	ld	hl, (dy_)
	ld	b, h		; dy
	ld	c, l
	srl	h		; err = dy / 2;
	rr	l
	exx
	ld	bc, (dy_)	; cnt = dy;
	inc	bc
ly1:
	ld	(hl), a		; *addr = mask;
				; step_y();
	ld	de, (ys_)
	add	hl, de
	exx
	or	a
	sbc	hl, de		; err -= dx;
	exx
	jr	nc, ly3		; if (err < 0) {
	exx
	add	hl, bc		; err += dy;
	exx
				; step_x();
	rrca
	jr	nc, ly3
	inc	hl
ly3:
	dec	bc		; cnt--;
	ld	e, a
	ld	a, b
	or	c
	ld	a, e
	jp	nz, ly1
	ret

abs:
	bit	7, h
	ret	z
	ex	de, hl
	ld	hl, 0
	or	a
	sbc	hl, de
	ret

color_:	ds	2
y1_:	ds	2
x1_:	ds	2
y0_:	ds	2
x0_:	ds	2

dx_:	ds	2
dy_:	ds	2
ys_:	ds	2
#endasm

void main(void)
{
	static int i, x, y;

	for (i = 0; i < 320; i++) {
		x = i + i;
		line(x, 0, 639 - x, 199, i & 7);
	}
	for (i = 0; i < 100; i++) {
		y = i + i;
		line(639, y, 0, 199 - y, i & 7);
	}
}
