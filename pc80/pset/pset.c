//zcc +pc80 -compiler=sdcc --list pset.c -create-app

#define BYTE unsigned char
unsigned int vram = 0xf300;

void crtset()
{
__asm
	ld	bc, 0000h
	call	08f7h		; ファンクションキー、カラー／白黒
	ld	bc, 80*256+25
	call	093ah		; WIDTHの設定
	call	0bd2h		; カーソル off
__endasm;
}

void cls()
{
__asm
	ld	hl, (_vram)

	ld	c, 64h
	out	(c), l
	out	(c), h
	ld	a, h
	xor	20h
	ld	h, a
	ld	(_vram), hl

	ld	de, 40
	xor	a
	ld	c, 25
cls1:
	ld	b, 80
cls2:
	ld	(hl), a
	inc	hl
	djnz	cls2
	add	hl, de
	dec	c
	jp	nz, cls1
__endasm;
}

void pset(BYTE x, BYTE y)
{
	char *p = (char *)(vram + y/4 * 120 + x/2);
	*p |= 0x01 << (x%2 * 4 + y%4);
}

#define SCALE 32
void fpset(int fx, int fy)
{
	BYTE px = 80 + fx * SCALE / 256;
	BYTE py = 50 + fy * SCALE / 256;
	pset(px, py);
}

#include "sint.h"
#define FOV 8
BYTE dir = 0;

void draw()
{
	BYTE t, i;
	int s, c, ds, dc, px, py;

	t = dir;
	s = sint[t];
	t += 64;
	c = sint[t];
	ds = s / (FOV*2);
	dc = c / (FOV*2);

	cls();	// 画面クリア

	// 投影面
	px = c;
	py = s;
	fpset(px, py);
	for (i = 0; i < FOV; i++) {
		px -= ds;
		py += dc;
		fpset(px, py);
	}
	px = c;
	py = s;
	for (i = 0; i < FOV; i++) {
		px += ds;
		py -= dc;
		fpset(px, py);
	}

	// 正面線
	px = c;
	py = s;
	fpset(0, 0);
	for (i = 0; i < FOV; i++) {
		px -= dc;
		py -= ds;
		fpset(px, py);
	}
}

void main()
{
	char *p, *q;
	int i;

	crtset();	// 画面設定
	cls();		// 画面クリア

	p = (char *)(0xf300 + 81);
	for (i = 0; i < 25; i++) {
		*p = 0x80;
		p += 120;
	}

	p = (char *)0xf300;
	q = (char *)0xd300;
	for (i = 0; i < 3000; i++) {
		*q++ = *p++;
	}

	for ( ; ; dir++) {
		draw();
	}
}
