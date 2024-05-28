; z80asm -b -l pline
; z88dk-appmake +pc88 -b pline.bin --org 0xb000

swap macro p1, p2
	ld	hl, (p1)
	ld	de, (p2)
	ld	(p2), hl
	ld	(p1), de
endm

	org	$b000

; void pline(x0, y0, x1, y1, plane)

	ld	(svsp), sp
	push	bc		; [
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	(_x0), bc	; x0
	ex	de, hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	(_y0), bc	; y0
	pop	hl		; ]

	di
	ld	sp, hl
	pop	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	(_x1), bc	; x1
	pop	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ld	(_y1), bc	; y1
	pop	hl
	ld	a, (hl)
	ld	(_plane), a	; plane
	ld	sp, 0
svsp	equ	$ - 2
	ei

	; プレーン port
	ld	a, (_plane)
	add	a, $5c
	ld	(oplane), a

;	const steep = Math.abs(y1 - y0) > Math.abs(x1 - x0);
;	if (steep) {
;		[x0, y0] = [y0, x0];
;		[x1, y1] = [y1, x1];
;	}

	ld	hl, (_y1)	; abs(y1 - y0)
	ld	de, (_y0)
	or	a
	sbc	hl, de
	jr	nc, L1

	ex	de, hl
	ld	hl, 0
	or	a
	sbc	hl, de
L1:
	push	hl	; [

	ld	hl, (_x1)	; abs(x1 - x0)
	ld	de, (_x0)
	or	a
	sbc	hl, de
	jr	nc, L2

	ex	de, hl
	ld	hl, 0
	or	a
	sbc	hl, de
L2:
	pop	de	; ]
	xor	a		; nop
	sbc	hl, de		; abs(dx) - abs(dy)
	jr	nc, L3

	swap _x0, _y0
	swap _x1, _y1
	ld	a, $eb		; ex de,hl
L3:
	ld	(steep), a

;	if (x0 > x1) {
;		[x0, x1] = [x1, x0];
;		[y0, y1] = [y1, y0];
;	}
;	let dx = x1 - x0;
;	let err = Math.floor(dx / 2);

	ld	hl, (_x1)
	ld	de, (_x0)
	or	a
	sbc	hl, de
	jr	nc, L4

	swap _y0, _y1
	ld	hl, (_x0)
	ld	de, (_x1)
	ld	(_x1), hl
	ld	(_x0), de
	or	a
	sbc	hl, de
L4:
	ld	(_dx), hl
	sra	h
	rr	l
	ld	(_err), hl

;	let dy = y1 - y0;
;	let sy = 1;
;	if (dy < 0) {
;		dy = -dy;
;		sy = -1;
;	}

	ld	hl, (_y1)
	ld	de, (_y0)
	or	a
	sbc	hl, de
	ld	a, $34		; inc (hl)
	jr	nc, L5

	ex	de, hl
	ld	hl, 0
	or	a
	sbc	hl, de
	ld	a, $35		; dec (hl)
L5:
	ld	(_dy), hl
	ld	(step_y), a

;	for ( ; x0 <= x1; x0++) {
;		if (steep) pset(y0, x0); else pset(x0, y0);
;		err -= dy;
;		if (err < 0) {
;			y0 += sy;
;			err += dx;
;		}
;	}

loop:
	ld	hl, (_x0)
	ld	de, (_y0)
	nop			; / ex de,hl
steep	equ	$ - 1
	call	ppset

	ld	hl, (_err)
	ld	de, (_dy)
	or	a
	sbc	hl, de		; err += (-dy)
	ld	(_err), hl	; err -= dy
	jr	nc, L11		; if (err < 0)

	ld	de, (_dx)
	add	hl, de
	ld	(_err), hl	; err += dx
	ld	hl, _y0		; y0 += sy
	nop			; inc/dec (hl) $34/$35
step_y	equ	$ - 1

L11:
	ld	hl, (_x1)
	ld	de, (_x0)
	or	a
	sbc	hl, de		; x0 + (-x1)
	inc	de
	ld	(_x0), de
	jp	nz, loop	; x0 <= x1

	ret

; hl = px, de = py
ppset:
	push	hl	; [
	push	de	; [[

	; ビット計算
	ld	a, l
	and	$07
	ld	hl, _btbl
	add	a, l
	ld	l, a
	jr	nc, ppset1
	inc	h
ppset1:
	ld	a, (hl)		; ビットマスク

	; アドレス計算 $c000 + 80 * y + x/8
	pop	hl	; ]]
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	e, l
	ld	d, h
	add	hl, hl
	add	hl, hl
	add	hl, de		; (64 + 16)倍
	ex	de, hl

	pop	hl	; ]
	rept 3
	srl	h
	rr	l
	endr
	add	hl, de
	add	hl, $c000

	di
	out	(0), a
oplane	equ	$ - 1
	or	(hl)
	ld	(hl), a
	out	($5f), a
	ei
	ret

_btbl:	db	$80,$40,$20,$10, $08,$04,$02,$01

_x0:	ds	2
_y0:	ds	2
_x1:	ds	2
_y1:	ds	2
_plane:	ds	1

_dx:	ds	2
_dy:	ds	2
_err:	ds	2
