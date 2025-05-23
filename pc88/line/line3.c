/*
zcc +pc88 line3.c -create-app
zcc +pc88 line3.c -create-app -subtype=disk
*/

void line(int x0, int y0, int x1, int y1);
#asm
_line:
				; args
	ld	hl, 2
	add	hl, sp
	ld	de, y1_
	ld	bc, 8
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
				; addr = (BYTE *)0xc000 + 80 * y0 + x0 / 8;
	ld	hl, (y0_)
	ld	d, h
	ld	e, l
	add	hl, hl
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	de, (x0_)
	srl	d
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e
	add	hl, de
	ld	de, $c000
	add	hl, de
	ld	(addr_), hl
				; mask = 0x80 >> (x0 % 8);
	ld	a, (x0_)
	and	$07
	ld	b, a
	inc	b
	ld	a, $01
L3:
	rrca
	djnz	L3
	ld	(mask_), a

	di
	out	($5e), a
				; if (dx >= dy) {
	ld	hl, (dx_)
	ld	de, (dy_)
	or	a
	sbc	hl, de
	jr	c, L4
	call	line_x
	jr	L5
L4:
				; } else {
	call	line_y
L5:
	out	($5f), a
	ei
	ret

line_x:
				; dy = -dy;
	ld	hl, 0
	ld	de, (dy_)
	or	a
	sbc	hl, de
	ld	(dy_), hl
				; err = dx / 2;
	ld	hl, (dx_)
	ld	b, h
	ld	c, l
	srl	h
	rr	l
	push	hl
	pop	iy
				; for (cnt = dx; cnt >= 0; cnt--) {
	ld	hl, (addr_)
lx1:
				; *addr |= mask;
	ld	a, (mask_)
	or	(hl)
	ld	(hl), a
				; step_x();
	call	step_x
				; err -= dy;
	ld	de, (dy_)
	add	iy, de
				; if (err < 0) {
	jr	c, lx2
				; err += dx;
	ld	de, (dx_)
	add	iy, de
				; step_y();
	ld	de, (ys_)
	add	hl, de
lx2:
	ld	a, b
	or	c
	ret	z
	dec	bc
	jp	lx1

line_y:
				; dx = -dx;
	ld	hl, 0
	ld	de, (dx_)
	or	a
	sbc	hl, de
	ld	(dx_), hl
				; err = dy / 2;
	ld	hl, (dy_)
	ld	b, h
	ld	c, l
	srl	h
	rr	l
	push	hl
	pop	iy
				; for (cnt = dy; cnt >= 0; cnt--) {
	ld	hl, (addr_)
ly1:
				; *addr |= mask;
	ld	a, (mask_)
	or	(hl)
	ld	(hl), a
				; step_y();
	ld	de, (ys_)
	add	hl, de
				; err -= dx;
	ld	de, (dx_)
	add	iy, de
				; if (err < 0) {
	jr	c, ly2
				; err += dy;
	ld	de, (dy_)
	add	iy, de
				; step_x();
	call	step_x
ly2:
	ld	a, b
	or	c
	ret	z
	dec	bc
	jp	ly1

step_x:
	ld	a, (mask_)
	rrca
	ld	(mask_), a
	ret	nc
	inc	hl
	ret

abs:
	bit	7, h
	ret	z
	ex	de, hl
	ld	hl, 0
	or	a
	sbc	hl, de
	ret

y1_:	ds	2
x1_:	ds	2
y0_:	ds	2
x0_:	ds	2

addr_:	ds	2	; hl / ix
mask_:	ds	1
dx_:	ds	2
dy_:	ds	2
ys_:	ds	2
;err_:	ds	2	; iy
;cnt_:	ds	2	; bc
#endasm

void main(void)
{
	static int i;
	for (i = 0; i < 640; i += 2) {
		line(i, 0, 639 - i, 199);
	}
	for (i = 0; i < 200; i += 2) {
		line(639, i, 0, 199 - i);
	}
}
