/*
zcc +pc88 line7.c -create-app -subtype=disk
*/
#include <stdlib.h>

typedef unsigned char BYTE;

BYTE *addr;
BYTE mask;
int dx, dy, ys, err, cnt;

void plane(void)
{
	if ((int)addr < 0) {
		outp(0x34, 0x67);	// G:nop R:nop B:or
	} else {
		outp(0x34, 0x57);	// G:nop R:or B:nop
	}
}

void pset(void)
{
	if ((int)addr < 0) {
		*(addr + 0xc000 + 16000) = mask;
	} else {
		*(addr + 0xc000) = mask;
	}
}

void step_x(void)
{
	mask >>= 1;
	if (mask == 0) {
		mask = 0x80;
		addr++;
	}
}

void step_y(void);
#asm
_step_y:
	ld	hl, (_addr)
	ld	de, (_ys)
	add	hl, de
	ld	(_addr), hl	; addr += ys;
	ret	nc
	call	_plane
	ret
#endasm

void line_xmajor(void)
{
	err = dx / 2;
	for (cnt = dx; cnt >= 0; cnt--) {
		pset();
		step_x();
		err -= dy;
		if (err < 0) {
			err += dx;
			step_y();
		}
	}
}

void line_ymajor(void)
{
	err = dy / 2;
	for (cnt = dy; cnt >= 0; cnt--) {
		pset();
		step_y();
		err -= dx;
		if (err < 0) {
			err += dy;
			step_x();
		}
	}
}

void line(int x0, int y0, int x1, int y1)
{
	dx = abs(x1 - x0);
	dy = abs(y1 - y0);
	if (x0 > x1) {
		int t;
		t = x0; x0 = x1; x1 = t;
		t = y0; y0 = y1; y1 = t;
	}
	ys = (y0 <= y1) ? 80 : -80;

	addr = (BYTE *)((y0 - 200) * 80 + (x0 >> 3));
	mask = 0x80 >> (x0 & 7);

	asm("di");
	outp(0x32, 0xd9);	// ALU
	outp(0x35, 0x80);	// GVRAM
	plane();

	if (dx > dy) {
		line_xmajor();
	} else {
		line_ymajor();
	}

	outp(0x32, 0xa9);
	asm("ei");
}

void main(void)
{
	// 640x400x1
	outp(0x31, 0x2a);	// 64KB RAM
//	outp(0x31, 0x28);	// ROM

	for (int x = 0; x < 640; x += 2) {
		line(x, 0, 639 - x, 399);
	}
	for (int y = 0; y < 400; y += 2) {
		line(639, y, 0, 399 - y);
	}
}
