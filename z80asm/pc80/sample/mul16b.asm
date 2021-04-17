; intel 8080 アセンブラ 16bit乗算 - Qiita
; https://qiita.com/ohisama@github/items/bdebca416501f9fa1201

	org	$d000

	ld	hl, 180
	ld	de, 180
	call	mul16
	call	printi
	jp	$5c66		; monitor

; hl = hl * de
mul16:
	ld	b, h
	ld	c, l
	ld	hl, 0
L1:
	srl	b
	rr	c
	jr	nc, L2
	add	hl, de
L2:
	xor	b
	ret	z
	ex	de, hl
	add	hl, hl
	ex	de, hl
	ld	a, d
	or	e
	jp	nz, L1
	ret

printi:
	ld	($0f0a8), hl	; FAcc
	ld	a, 2		; 整数
	ld	($0ef45), a
	call	$2d22		; FAccの内容を文字列に置き換える
	call	$52ed		; puts
	ld	a, $0d
	rst	$18
	ld	a, $0a
	rst	$18
	ret
