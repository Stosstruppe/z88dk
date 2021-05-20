			; 5.11 fixed base=2048
DA_	equ	94	; 0.0458
DB_	equ	171	; 0.08333
R4	equ	8192	; 4.0

	org	$d000

	call	init
	ld	hl, DB_*(-12)
	ld	c, 25
Ly:
	ld	(cb), hl
	ld	a, $0d
	rst	$18
	ld	a, $0a
	rst	$18
	ld	hl, DA_*(-39)
	ld	b, 79
Lx:
	ld	(ca), hl
	push	bc

;	ld	hl, (ca)
	ld	(a_), hl
	ld	hl, (cb)
	ld	(b_), hl
	call	pow
	xor	a
for_i:
	ld	(i_), a
				; b = 2*a*b + cb
	ld	bc, (a_)
	ld	de, (b_)
	call	mul
	add	hl, hl
	ld	de, (cb)
	add	hl, de
	ld	(b_), hl
				; a = a*a - b*b + ca
	ld	hl, (aa)
	ld	de, (bb)
	or	a
	sbc	hl, de
	ld	de, (ca)
	add	hl, de
	ld	(a_), hl

	call	pow
	ld	hl, (aa)
	ld	de, (bb)
	add	hl, de
	ld	de, R4
	sbc	hl, de
	jr	c, next_i
	ld	a, (i_)
	jp	exit_i
next_i:
	ld	a, (i_)
	cp	15
	inc	a
	jr	c, for_i
exit_i:
	ld	hl, hexstr
	add	a, l
	ld	l, a
	jr	nc, L1
	inc	h
L1:
	ld	a, (hl)
	rst	$18

	ld	hl, (ca)
	ld	de, DA_
	add	hl, de
	pop	bc
	djnz	Lx

	ld	hl, (cb)
	ld	de, DB_
	add	hl, de
	dec	c
	jp	nz, Ly
L9:
	halt
	jp	L9

pow:
	ld	bc, (a_)	; aa = a*a
	ld	d, b
	ld	e, c
	call	mul
	ld	(aa), hl
	ld	bc, (b_)	; bb = b*b
	ld	d, b
	ld	e, c
	call	mul
	ld	(bb), hl
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
;	ld	l, h		; hl = dehl>>8
;	ld	h, e
	ld	a, h		; hl = dehl>>11
	srl	d
	rr	e
	rra
	srl	d
	rr	e
	rra
	srl	d
	rr	e
	rra
	ld	h, e
	ld	l, a

	pop	af
	ret	p
	sub	a		; neg hl
	sub	l
	ld	l, a
	sbc	a, a
	sub	h
	ld	h, a
	ret

init:
	ld	bc, $0000
	call	$08f7		; function / color
	ld	bc, 80*256+25
	call	$093a		; width
	ret

hexstr:	db	"0123456789ABCDEF "
ca:	ds	2
cb:	ds	2	
a_:	ds	2
b_:	ds	2
aa:	ds	2
bb:	ds	2
i_:	ds	1
