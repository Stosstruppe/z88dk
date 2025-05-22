/*
zcc +pc88 line1.c -create-app
zcc +pc88 line1.c -create-app -subtype=disk
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
				; xs = (x0 <= x1) ? 0 : 1;
	ld	hl, (x1_)
	ld	de, (x0_)
	xor	a
	sbc	hl, de
	rla
	ld	(xs_), a
				; ys = (y0 <= y1) ? 80 : -80;
	ld	hl, (y1_)
	ld	de, (y0_)
	or	a
	sbc	hl, de
	ld	hl, 80
	jr	nc, L1
	ld	hl, -80
L1:
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
L2:
	rrca
	djnz	L2
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
				; err = dx / 2;
	ld	hl, (dx_)
	ld	(cnt_), hl
	srl	h
	rr	l
	ld	(err_), hl
				; for (cnt = dx; cnt >= 0; cnt--) {
lx1:
				; *addr |= mask;
	ld	hl, (addr_)
	ld	a, (mask_)
	or	(hl)
	ld	(hl), a
				; step_x();
	call	step_x
				; err -= dy;
	ld	hl, (err_)
	ld	de, (dy_)
	or	a
	sbc	hl, de
	ld	(err_), hl
				; if (err < 0) {
	jr	nc, lx2
				; err += dx;
	ld	de, (dx_)
	add	hl, de
	ld	(err_), hl
				; step_y();
	call	step_y
lx2:
	ld	hl, (cnt_)
	ld	a, h
	or	l
	ret	z
	dec	hl
	ld	(cnt_), hl
	jp	lx1

line_y:
				; err = dy / 2;
	ld	hl, (dy_)
	ld	(cnt_), hl
	srl	h
	rr	l
	ld	(err_), hl
				; for (cnt = dy; cnt >= 0; cnt--) {
ly1:
				; *addr |= mask;
	ld	hl, (addr_)
	ld	a, (mask_)
	or	(hl)
	ld	(hl), a
				; step_y();
	call	step_y
				; err -= dx;
	ld	hl, (err_)
	ld	de, (dx_)
	or	a
	sbc	hl, de
	ld	(err_), hl
				; if (err < 0) {
	jr	nc, ly2
				; err += dy;
	ld	de, (dy_)
	add	hl, de
	ld	(err_), hl
				; step_x();
	call	step_x
ly2:
	ld	hl, (cnt_)
	ld	a, h
	or	l
	ret	z
	dec	hl
	ld	(cnt_), hl
	jp	ly1

step_x:
	ld	a, (xs_)
	or	a
	ld	a, (mask_)
	jr	nz, sx1
	rrca
	ld	(mask_), a
	ret	nc
	ld	hl, (addr_)
	inc	hl
	ld	(addr_), hl
	ret
sx1:
	rlca
	ld	(mask_), a
	ret	nc
	ld	hl, (addr_)
	dec	hl
	ld	(addr_), hl
	ret

step_y:
				; addr += ys;
	ld	hl, (addr_)
	ld	de, (ys_)
	add	hl, de
	ld	(addr_), hl
	ret

abs:
	bit	7, h
	ret	z
	ex	de, hl
	ld	hl, 0
	or	a
	sbc	hl, de
	ret

addr_:	ds	2
mask_:	ds	1

y1_:	ds	2
x1_:	ds	2
y0_:	ds	2
x0_:	ds	2

dx_:	ds	2
dy_:	ds	2
xs_:	ds	1
ys_:	ds	2
err_:	ds	2
cnt_:	ds	2
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
