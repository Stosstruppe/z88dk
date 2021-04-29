yt	equ	$ce00
yb	equ	$cf00

	org	$d000

powt:	dw	0, 1, 4, 9, 16, 25, 36, 49
	dw	64, 81, 100, 121, 144, 169, 196, 225
	dw	256, 289, 324, 361, 400, 441, 484, 529
	dw	576, 625, 676, 729, 784, 841, 900, 961
	dw	1024, 1089, 1156, 1225, 1296, 1369, 1444, 1521
	dw	1600, 1681, 1764, 1849, 1936, 2025, 2116, 2209
	dw	2304, 2401, 2500, 2601, 2704, 2809, 2916, 3025
	dw	3136, 3249, 3364, 3481, 3600, 3721, 3844, 3969
	dw	4096, 4225, 4356, 4489, 4624, 4761, 4900, 5041
	dw	5184, 5329, 5476, 5625, 5776, 5929, 6084, 6241
	dw	6400, 6561, 6724, 6889, 7056, 7225, 7396, 7569
	dw	7744, 7921, 8100, 8281, 8464, 8649, 8836, 9025
	dw	9216, 9409, 9604, 9801, 10000, 10201, 10404, 10609
	dw	10816, 11025, 11236, 11449, 11664, 11881, 12100, 12321
	dw	12544, 12769, 12996, 13225, 13456, 13689, 13924, 14161
	dw	14400, 14641, 14884, 15129, 15376, 15625, 15876, 16129
	dw	16384, 16641, 16900, 17161, 17424, 17689, 17956, 18225
	dw	18496, 18769, 19044, 19321, 19600, 19881, 20164, 20449
	dw	20736, 21025, 21316, 21609, 21904, 22201, 22500, 22801
	dw	23104, 23409, 23716, 24025, 24336, 24649, 24964, 25281
	dw	25600, 25921, 26244, 26569, 26896, 27225, 27556, 27889
	dw	28224, 28561, 28900, 29241, 29584, 29929, 30276, 30625
	dw	30976, 31329, 31684, 32041, 32400, 32761, 33124, 33489
	dw	33856, 34225, 34596, 34969, 35344, 35721, 36100, 36481
	dw	36864, 37249, 37636, 38025, 38416, 38809, 39204, 39601
	dw	40000, 40401, 40804, 41209, 41616, 42025, 42436, 42849
	dw	43264, 43681, 44100, 44521, 44944, 45369, 45796, 46225
	dw	46656, 47089, 47524, 47961, 48400, 48841, 49284, 49729
	dw	50176, 50625, 51076, 51529, 51984, 52441, 52900, 53361
	dw	53824, 54289, 54756, 55225, 55696, 56169, 56644, 57121
	dw	57600, 58081, 58564, 59049, 59536, 60025, 60516, 61009
	dw	61504, 62001, 62500, 63001, 63504, 64009, 64516, 65025

cost:	dw	256, 256, 256, 255, 255, 254, 253, 252
	dw	251, 250, 248, 247, 245, 243, 241, 239
	dw	237, 234, 231, 229, 226, 223, 220, 216
	dw	213, 209, 206, 202, 198, 194, 190, 185
	dw	181, 177, 172, 167, 162, 157, 152, 147
	dw	142, 137, 132, 126, 121, 115, 109, 104
	dw	98, 92, 86, 80, 74, 68, 62, 56
	dw	50, 44, 38, 31, 25, 19, 13, 6
	dw	0, -6, -13, -19, -25, -31, -38, -44
	dw	-50, -56, -62, -68, -74, -80, -86, -92
	dw	-98, -104, -109, -115, -121, -126, -132, -137
	dw	-142, -147, -152, -157, -162, -167, -172, -177
	dw	-181, -185, -190, -194, -198, -202, -206, -209
	dw	-213, -216, -220, -223, -226, -229, -231, -234
	dw	-237, -239, -241, -243, -245, -247, -248, -250
	dw	-251, -252, -253, -254, -255, -255, -256, -256
	dw	-256, -256, -256, -255, -255, -254, -253, -252
	dw	-251, -250, -248, -247, -245, -243, -241, -239
	dw	-237, -234, -231, -229, -226, -223, -220, -216
	dw	-213, -209, -206, -202, -198, -194, -190, -185
	dw	-181, -177, -172, -167, -162, -157, -152, -147
	dw	-142, -137, -132, -126, -121, -115, -109, -104
	dw	-98, -92, -86, -80, -74, -68, -62, -56
	dw	-50, -44, -38, -31, -25, -19, -13, -6
	dw	0, 6, 13, 19, 25, 31, 38, 44
	dw	50, 56, 62, 68, 74, 80, 86, 92
	dw	98, 104, 109, 115, 121, 126, 132, 137
	dw	142, 147, 152, 157, 162, 167, 172, 177
	dw	181, 185, 190, 194, 198, 202, 206, 209
	dw	213, 216, 220, 223, 226, 229, 231, 234
	dw	237, 239, 241, 243, 245, 247, 248, 250
	dw	251, 252, 253, 254, 255, 255, 256, 256

mask:	db	$01,$10,$02,$20,$04,$40,$08,$80

	; gd408
	call	init

	ld	hl, yt		; yt[] = 100
	ld	a, 100
L1:
	ld	(hl), a
	inc	l
	jp	nz, L1
	ld	hl, yb		; yb[] = 0
	xor	a
L2:
	ld	(hl), a
	inc	l
	jp	nz, L2

	ld	a, 66
	ld	(py), a		; py = 42 + 24
	ld	a, -24		; for (y = -24; y <= 24; y++)
Lout:
	ld	(y), a
	ld	l, a		; y退避
	neg
	add	a, 32
	ld	(px), a		; px = 80 - 48 - y
	ld	a, l
	call	pow
	ld	(yy), de	; yy = pow(y, 2)
	ld	a, -24		; for (x = -24; x <= 24; x++)
Lin:
	ld	(x), a
	call	calc

	ld	hl, px		; px += 2
	inc	(hl)
	inc	(hl)
	ld	a, (x)
	inc	a
	cp	24+1
	jp	nz, Lin

	ld	hl, py		; py--
	dec	(hl)
	ld	a, (y)
	inc	a
	cp	24+1
	jp	nz, Lout
L9:
	halt
	jp	L9

; a: x
calc:
	call	pow		; de = x**2
	ld	hl, (yy)
	add	hl, de		; hl = x**2 + y**2
	ld	e, l		; hl *= 28
	ld	d, h
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, hl		; end
	call	sqr		; a = t

	ld	c, a		; c = t
	call	cos		; de = cos(t)
	ld	l, e		; hl *= 25
	ld	h, d
	add	hl, hl
	add	hl, de
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de		; end
	push	hl		; z1 = cos(t) * 25

	ld	a, c		; a = 3*t
	add	a, a
	add	a, c
	call	cos		; de = cos(3*t)
	ld	l, e		; hl *= 7.5
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	sra	d
	rr	e
	add	hl, de		; end
	ex	de, hl		; z2 = cos(3*t) * 7.5

	ld	bc, (px)	; c = px
	ld	h, b
	ld	l, 0
	add	hl, de		; z2
	pop	de
	sbc	hl, de		; z1
	ld	b, h		; b = py - z1 + z2

	ld	e, 0		; e = 0
	ld	l, c		; c = px
	ld	h, yt/256	; (hl) = yt[px]
	ld	a, b
	cp	(hl)		; if (yt[px] > py)
	jr	nc, calc1
	ld	(hl), b
	inc	e
calc1:
	ld	h, yb/256	; (hl) = yb[px]
	ld	a, (hl)
	cp	b		; if (yb[px] < py)
	jr	nc, calc2
	ld	(hl), b
	inc	e
calc2:
	ld	a, e		; if (e) pset
	or	a
	ret	z
	call	pset
	ret

; de = cos(a)
cos:
	ld	l, a
	ld	h, cost/512
	add	hl, hl
	ld	e, (hl)
	inc	l
	ld	d, (hl)
	ret

; de = pow(a, 2)
pow:
	ld	l, a
	neg
	jp	m, pow1
	ld	l, a
pow1:
	ld	h, powt/512
	add	hl, hl
	ld	e, (hl)
	inc	l
	ld	d, (hl)
	ret

; a = sqr(hl)
sqr:
	ld	(sqr_x+1), hl
	ld	a, 128
	ld	b, a
sqr1:
	srl	b		; b >>= 1
	jr	c, sqr3		; if (b == 0) break

	ld	l, a
	ld	h, powt/512
	add	hl, hl
	ld	e, (hl)
	inc	l
	ld	d, (hl)
sqr_x:	ld	hl, 0
	sbc	hl, de		; x - powt[a]
	jr	nc, sqr2
	sub	b		; a -= b
	jp	sqr1
sqr2:
	add	a, b		; a += b
	jp	sqr1
sqr3:
	ld	l, a
	ld	h, powt/512
	add	hl, hl
	ld	e, (hl)
	inc	l
	ld	d, (hl)
	ld	hl, (sqr_x+1)
	sbc	hl, de		; x - powt[a]
	ret	nc
	dec	a		; if (c < 0) a--
	ret

; b: y (0〜99)
; c; x (0〜159)
; addr = $f300 + (y/4)*120 + x/2
; mask = $01 << (x%2*4 + y%4)
pset:
	ld	a, c
	cp	160
	ret	nc		; if (x - 160 >= 0) return
	ld	a, b
	cp	100
	ret	nc		; if (y - 100 >= 0) return

	rra
	and	$3e		; a = (y/4)*2
	add	a, $75
	ld	l, a
	ld	h, $06		; hl = $0675 + a
	ld	e, (hl)
	inc	l
	ld	d, (hl)		; de = $f300 + (y/4)*120
	ld	l, c
	srl	l
	ld	h, 0		; hl = x/2
	add	hl, de		; hl = addr

	ld	a, b
	ld	e, c
	rr	e		; cy = x>>1
	rla			; a = y<<1 + cy
	and	$07		; a = yyx
	ex	de, hl
	ld	l, a
	ld	h, mask/256
	ld	a, (hl)		; a = mask[a]
	ex	de, hl
	or	(hl)
	ld	(hl), a
	ret

init:
	ld	hl, color
	call	$0951		; color
	ld	bc, 80*256+25
	call	$093a		; width
	ret
color:	db	"0,0,1", 0	; 低解像度グラフィック

x:	ds	1
y:	ds	1
yy:	ds	2
px:	ds	1
py:	ds	1
