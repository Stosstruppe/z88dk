; ANSIで保存

	org	$d000

powtbl:	dw	0, 1, 4, 9, 16, 25, 36, 49
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

t64_48:	db	-67,-65,-64,-63,-61,-60,-59,-57,-56,-55
	db	-53,-52,-51,-49,-48,-47,-45,-44,-43,-41
	db	-40,-39,-37,-36,-35,-33,-32,-31,-29,-28
	db	-27,-25,-24,-23,-21,-20,-19,-17,-16,-15
	db	-13,-12,-11,-9,-8,-7,-5,-4,-3,-1
	db	0,1,3,4,5,7,8,9,11,12
	db	13,15,16,17,19,20,21,23,24,25
	db	27,28,29,31,32,33,35,36,37,39
	db	40,41,43,44,45,47,48,49,51,52
	db	53,55,56,57,59,60,61,63,64,65

sx:	ds	1	; screen 0..99
sy:	ds	1
px:	ds	1	; pos -64..64
py:	ds	1
pz:	ds	1
yy:	ds	2	; y**2
tmp:	ds	2
filler:	ds	256-109

		; $d300
mask:	db	$01,$04,$12,$48,$13,$4c,$33,$cc

		; $d308
	call	init

	xor	a
Lout:
	ld	(sy), a
	call	s2p
	ld	(py), a
	call	pow
	ld	(yy), de
	xor	a
Lin:
	ld	(sx), a
	call	calc

	ld	a, (sx)
	add	a, 2
	cp	100
	jp	c, Lin

	ld	a, (sy)
	add	a, 2
	cp	100
	jp	c, Lout
L9:
	halt
	jp	L9

; a: sx
calc:
	call	s2p
	ld	(px), a
	call	pow		; de = x**2
	ld	hl, (yy)
	add	hl, de
	ex	de, hl
	ld	hl, 64*64
	sbc	hl, de		; zz = sqrt(rr - (xx + yy))
	ret	c

	ld	a, l
	ld	l, h
	call	sqrt
	ld	a, d		; z = sqrt(zz)
	ld	(pz), a

	call	dot
	or	a
	jp	p, calc1
	xor	a
calc1:
	rra
	rra
	rra
	rra
	and	$03

	ld	bc, (sx)
	ld	l, a
	ld	a, c
	add	a, 30
	ld	c, a
	ld	a, l
	srl	c
	srl	b
	call	qpset
	ret

; screen to pos
; a = s2p(a)
s2p:
	ld	l, a
	ld	h, t64_48/256
	ld	a, (hl)
	ret

; hl = pow(a, 2)
pow:
	or	a
	jp	p, pow1
	neg
pow1:
	ld	l, a
	ld	h, powtbl/512
	add	hl, hl
	ld	e, (hl)
	inc	l
	ld	d, (hl)
	ret

; d = sqrt(la)
sqrt:
	ld	de, 0040h
	ld	h, d
	ld	b, 7
	or	a
sqrt1:
	sbc	hl, de
	jr	nc, sqrt2
	add	hl, de
sqrt2:
	ccf
	rl	d
	rla
	adc	hl, hl
	rla
	adc	hl, hl
	djnz	sqrt1
	sbc	hl, de
	ccf
	rl	d
	ret

dot:
	ld	a, (px)
	ld	l, 43
	call	mul8s
	ld	a, h
	ld	(tmp), a
	ld	a, (py)
	ld	l, -21
	call	mul8s
	ld	a, h
	ld	(tmp+1), a
	ld	a, (pz)
	ld	l, 43
	call	mul8s
	ld	a, h
	ld	hl, (tmp)
	add	a, h
	add	a, l
	ret

; hl = a * l
mul8s:
	ld	e, a
	ld	d, 80h
;	ld	a, e
	xor	d
	ld	e, a
				; 1st
	srl	l
	jr	c, mul1
	ld	a, d
mul1:
	srl	a
	rr	l
				; 2-7
	ld	b, 6
mul2:
	jr	nc, mul3
	add	a, e
	jp	mul4
mul3:
	add	a, d
mul4:
	rra
	rr	l
	djnz	mul2
				; final
	jr	nc, mul5
	ld	h, a
	ld	a, e
	cpl
	add	a, h
	jp	mul6
mul5:
	add	a, 7fh
mul6:
	rra
	rr	l
	add	a, 81h
	ld	h, a
				; hl <<= 2
	add	hl, hl
	add	hl, hl
	ret

; b: y 0-49 yh=y/2 yl=y%2
; c: x 0-79
; l: dot 0-3
qpset:
	ld	a, c
	cp	80
	ret	nc		; if (x >= 80) return
	ld	a, b
	cp	50
	ret	nc		; if (y >= 50) return
	push	hl

	ld	a, b
	and	$3e		; a = yh*2
	add	a, $75
	ld	l, a
	ld	h, $06		; hl = $0675 + a
	ld	e, (hl)
	inc	l
	ld	d, (hl)		; de = $f300 + 120*yh
	ld	l, c
	ld	h, 0
	add	hl, de
	ex	de, hl		; de += x

	pop	hl
	srl	b
	rl	l		; %ddy
	ld	h, mask/256
	ld	a, (hl)
	ex	de, hl
	or	(hl)
	ld	(hl), a
	ret

init:
	ld	bc, $0000
	call	$08f7		; function / color
	ld	hl, color
	call	$0951		; color
	ld	bc, 80*256+25
	call	$093a		; width
	ret
color:	db	"0,0,1", 0	; 低解像度グラフィック
