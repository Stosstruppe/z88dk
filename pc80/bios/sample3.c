//zcc +pc80 -compiler=sdcc --list sample3.c -create-app

typedef unsigned long FLOAT;	// exp:8 sign:1 frac:23

void bcde() __naked
{
	__asm
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ret
	__endasm;
}

void printFAcc() __naked
{
	__asm
	call	2d22h		; FAccの内容を文字列に置き換える
	jp	52edh		; puts
	__endasm;
}

void setFloat(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	ld	de, 0f0a8h	; FAcc
	ld	bc, 4
	ldir
	ld	a, 4		; 単精度浮動小数
	ld	(0ef45h), a
	ret
	__endasm;
}

void mulFloat(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	call	_bcde
	jp	2541h		; 単精度乗算 (FAcc)←(bc de)*(FAcc)
	__endasm;
}

void atn() __naked
{
	__asm
	jp	3372h
	__endasm;
}

void main()
{
	FLOAT f1 = 0x81000000;	// 1.0
	FLOAT f4 = 0x83000000;	// 4.0

	// atn(1) * 4
	setFloat(&f1);
	atn();
	mulFloat(&f4);
	printFAcc();
}
