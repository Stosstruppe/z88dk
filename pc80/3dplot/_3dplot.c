// ANSIで保存
// zcc +pc80 -compiler=sdcc --list _3dplot.c -create-app

typedef unsigned char BYTE;
typedef unsigned long FLOAT;

int geti() __naked
{
	__asm
	call	277fh		; CINT
	ld	hl, (0f0a8h)	; FAcc
	ret
	__endasm;
}

void seti(short x) __z88dk_fastcall __naked
{
	x;
	__asm
	ld	(0f0a8h), hl	; FAcc
	ld	a, 2		; 整数
	ld	(0ef45h), a
	jp	27b3h		; CSNG
	__endasm;
}

void hl2bcde() __naked
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

void getf(FLOAT *p) __z88dk_fastcall __naked
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

void setf(FLOAT *p) __z88dk_fastcall __naked
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

void addf(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	call	_hl2bcde
	jp	2412h		; 単精度加算
	__endasm;
}

void subf(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	call	_hl2bcde
	jp	240fh		; 単精度減算 (FAcc)←(bc de)-(FAcc)
	__endasm;
}

void mulf(FLOAT *p) __z88dk_fastcall __naked
{
	p;
	__asm
	call	_hl2bcde
	jp	2541h		; 単精度乗算 (FAcc)←(bc de)*(FAcc)
	__endasm;
}

void cos() __naked
{
	__asm
	jp	32f6h
	__endasm;
}

void sqr() __naked
{
	__asm
	jp	31a1h
	__endasm;
}

void init() __naked
{
	__asm
	ld	hl, color
	call	0951h		; color
	ld	bc, 80*256+25
	call	093ah		; width
	ret

color:	db	"0,0,1",0	; 低解像度グラフィック
	__endasm;
}

void pset(BYTE x, BYTE y)
{
	if (x >= 160 || y >= 100) return;
	char *p = (char *)0xf300 + y/4 * 120 + x/2;
	*p |= 0x01 << (x%2 * 4 + y%4);
}

const FLOAT torad = 0x7b0efa35;	// 3.14159265 / 180
const FLOAT f100 = 0x87480000;
const FLOAT f30 = 0x85700000;

void main()
{
	FLOAT rad, t;
	BYTE px, py;
	int x, y, z;

	init();
	for (y = -180; y <= 180; y += 8) {
		for (x = -180; x <= 180; x += 8) {

			// rad = sqr(x*x + y*y) * torad
			seti(x * x);
			getf(&t);
			seti(y * y);
			addf(&t);
			sqr();
			mulf(&torad);
			getf(&rad);

			// z = cos(rad) * 100 - cos(3*rad) * 30
			//setf(&rad);
			cos();
			mulf(&f100);
			getf(&t);
			seti(3);
			mulf(&rad);
			cos();
			mulf(&f30);
			subf(&t);
			z = geti();

			px = 80 + x/4 - y/8;
			py = 42 - (y/8 + z/4);
			pset(px, py);
		}
	}
}
