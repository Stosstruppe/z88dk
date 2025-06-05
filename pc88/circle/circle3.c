/*
zcc +pc88 circle3.c -create-app -subtype=disk
*/

void circle(int xm, int ym, int r);
#asm
_circle:
	ld	hl, 2
	add	hl, sp
	ld	de, r_
	ld	bc, 6
	ldir

	di
	ld	a, $d9
	out	($32), a	; ALU
	ld	a, $80
	out	($35), a	; GVRAM
	ld	a, 5
	out	($34), a	; GRB

			; x = -r;
	ld	hl, (r_)
	call	neg_hl
	ld	(x_), hl
			; y = 0;
	ld	hl, 0
	ld	(y_), hl
			; err = 2 - 2 * r;
	ld	hl, (r_)
	add	hl, hl
	ex	de, hl
	ld	hl, 2
	sbc	hl, de
	ld	(err_), hl
L1:
			; pset(-x, +y);
	ld	de, (y_)
	ld	hl, (x_)
	call	neg_hl
	call	pset
			; pset(-y, -x);
	ld	hl, (x_)
	call	neg_hl
	ex	de, hl
	ld	hl, (y_)
	call	neg_hl
	call	pset
			; pset(+x, -y);
	ld	hl, (y_)
	call	neg_hl
	ex	de, hl
	ld	hl, (x_)
	call	pset
			; pset(+y, +x);
	ld	de, (x_)	; y
	ld	hl, (y_)	; x
	call	pset
			; r = err;
	ld	hl, (err_)
	ld	(r_), hl
			; if (r <= y)
	ld	hl, (y_)
	ld	de, (r_)
	or	a
	sbc	hl, de
	jp	m, L2
			; err += ++y * 2 + 1;
	ld	hl, (y_)
	inc	hl
	ld	(y_), hl
	add	hl, hl
	inc	hl
	ex	de, hl
	ld	hl, (err_)
	add	hl, de
	ld	(err_), hl
L2:
			; if (r > x || err > y)
	ld	hl, (r_)
	ld	de, (x_)
	or	a
	sbc	hl, de
	jr	z, L3
	jp	m, L3
	jp	L4
L3:
	ld	hl, (err_)
	ld	de, (y_)
	or	a
	sbc	hl, de
	jr	z, L5
	jp	m, L5
L4:
			; err += ++x * 2 + 1;
	ld	hl, (x_)
	inc	hl
	ld	(x_), hl
	add	hl, hl
	inc	hl
	ex	de, hl
	ld	hl, (err_)
	add	hl, de
	ld	(err_), hl
L5:
			; } while (x < 0);
	ld	hl, (x_)
	bit	7, h
	jp	nz, L1

	ld	a, $a9
	out	($32), a
	ei
	ret

; hl	x
; de	y
pset:
	ld	bc, (xm_)
	add	hl, bc	; x += xm;
	ld	a, l
	ex	de, hl	; de=x, hl=y
			; 0xc000 + (y*80) + (x>>3);
	ld	bc, (ym_)
	add	hl, bc	; y += ym
	ld	b, h
	ld	c, l
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	srl	d
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e
	add	hl, de
	ld	de, $c000
	add	hl, de
			; 0x80 >> (x&7);
	and	a, $07
	ld	b, a
	ld	a, $01
	inc	b
pset2:
	rrca
	djnz	pset2
	ld	(hl), a
	ret

neg_hl:
	ex	bc, hl
	ld	hl, 0
	or	a
	sbc	hl, bc
	ret

r_:	ds	2
ym_:	ds	2
xm_:	ds	2
x_:	ds	2
y_:	ds	2
err_:	ds	2

#endasm

void main(void)
{
	circle(320, 100, 90);
}
