//zcc +pc80 -compiler=sdcc --list sample2.c -create-app

typedef unsigned long FLOAT;	// exp:8 sign:1 frac:23

void printFAcc() __naked
{
	__asm
	call	2d22h		; FAcc to str
	jp	52edh
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
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	jp	2541h		; 単精度乗算 (FAcc)←(bc de)*(FAcc)
	__endasm;
}

void main()
{
	FLOAT x = 0x818ccccd;	// -1.1
	FLOAT y = 0x80000000;	// 0.5

	setFloat(&x);
	mulFloat(&y);
	printFAcc();
}
