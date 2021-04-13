//zcc +pc80 -compiler=sdcc --list aafloat.c -create-app

typedef unsigned long FLOAT;

void putch(char c) __z88dk_fastcall __naked
{
	c;
	__asm
	ld	a, l
	rst	18h
	ret
	__endasm;
}

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

void getFloat(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	ex	de, hl
	ld	hl, 0f0a8h	; FAcc
	ldi
	ldi
	ldi
	ldi
	ret
	__endasm;
}

void setFloat(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	ld	de, 0f0a8h	; FAcc
	ldi
	ldi
	ldi
	ldi
	ld	a, 4		; 単精度浮動小数
	ld	(0ef45h), a
	ret
	__endasm;
}

void addFloat(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	call	_bcde
	jp	2412h		; 単精度加算
	__endasm;
}

void subFloat(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	call	_bcde
	jp	240fh		; 単精度減算 (FAcc)←(bc de)-(FAcc)
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

signed char cmpFloat(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	call	_bcde
	call	270ch		; 単精度比較
	ld	l, a		; FAcc ? p <:ff =:00 >:01
	ret
	__endasm;
}

void setShort(short v) __z88dk_fastcall __naked
{
	v;
	__asm
	ld	(0f0a8h), hl	; FAcc
	ld	a, 2		; 整数
	ld	(0ef45h), a
	jp	27b3h		; CSNG
	__endasm;
}

void printFAcc() __naked
{
	__asm
	call	2d22h		; FAccの内容を文字列に置き換える
	jp	52edh		; puts
	__endasm;
}

void main()
{
	int i, x, y;
	FLOAT a, b, ca, cb, t;
	FLOAT f4 = 0x83000000;
	FLOAT f_0458 = 0x7c3b98c8;
	FLOAT f_08333 = 0x7d2aa8eb;

	for (y = -12; y <= 12; y++) {
		for (x = -39; x <= 39; x++) {
			// ca = x * 0.0458;
			setShort(x);
			mulFloat(&f_0458);
			getFloat(&ca);
			getFloat(&a);

			// cb = y * 0.08333;
			setShort(y);
			mulFloat(&f_08333);
			getFloat(&cb);
			getFloat(&b);

			for (i = 0; i <= 15; i++) {
				// t = a * a - b * b + ca;
				setFloat(&a);
				mulFloat(&a);
				getFloat(&t);
				setFloat(&b);
				mulFloat(&b);
				subFloat(&t);
				addFloat(&ca);
				getFloat(&t);

				// b = 2 * a * b + cb;
				setShort(2);
				mulFloat(&a);
				mulFloat(&b);
				addFloat(&cb);
				getFloat(&b);

				// a = t;
				setFloat(&t);
				getFloat(&a);

				// if (a * a + b * b > 4)
				setFloat(&a);
				mulFloat(&a);
				getFloat(&t);
				setFloat(&b);
				mulFloat(&b);
				addFloat(&t);
				if (cmpFloat(&f4) > 0) {
					break;
				}
			}
			putch("0123456789ABCDEF "[i]);
		}
		putch('\r');
		putch('\n');
	}
}

/*
C++ https://ideone.com/NEysqi
#include <stdio.h>
int main()
{
	int i, x, y;
	float a, b, ca, cb, t;

	for (y = -12; y <= 12; y++) {
		for (x = -39; x <= 39; x++) {
			ca = x * 0.0458;
			cb = y * 0.08333;
			a = ca;
			b = cb;
			for (i = 0; i <= 15; i++) {
				t = a * a - b * b + ca;
				b = 2 * a * b + cb;
				a = t;
				if (a * a + b * b > 4) {
					break;
				}
			}
			putc("0123456789ABCDEF "[i], stdout);
		}
		putc('\n', stdout);
	}
}
*/
