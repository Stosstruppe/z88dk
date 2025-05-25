/*
zcc +pc88 line4.c -create-app
zcc +pc88 line4.c -create-app -subtype=disk
*/
#include <stdlib.h>

typedef unsigned char BYTE;

int dx, dy, ys, cnt, err;
BYTE *addr, mask;

void step_x(void)
{
	mask >>= 1;
	if (mask) return;
	mask = 0x80;
	addr++;
}

void step_y(void)
{
	addr += ys;
}

void line_xmajor(void)
{
	err = dx / 2;
	for (cnt = dx; cnt >= 0; cnt--) {
		*addr = mask;
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
		*addr = mask;
		step_y();
		err -= dx;
		if (err < 0) {
			err += dy;
			step_x();
		}
	}
}

int line(int x0, int y0, int x1, int y1, int c)
{
	static int t;

	dx = abs(x1 - x0);
	dy = abs(y1 - y0);
	if (x0 > x1) {
		t = x0; x0 = x1; x1 = t;
		t = y0; y0 = y1; y1 = t;
	}
	addr = (BYTE *)0xc000 + (y0 * 80) + (x0 >> 3);
	mask = 0x80 >> (x0 & 7);
	ys = (y0 <= y1) ? 80 : -80;

	asm("di");
	outp(0x32, 0xd9);
	outp(0x35, 0x80);
	outp(0x34, c);
	if (dx > dy) {
		line_xmajor();
	} else {
		line_ymajor();
	}
	outp(0x32, 0xa9);
	asm("ei");
	return 0;
}

void main(void)
{
	static int i, x, y;

	for (i = 0; i < 320; i++) {
		x = i + i;
		line(x, 0, 639 - x, 199, i & 7);
	}
	for (i = 0; i < 100; i++) {
		y = i + i;
		line(639, y, 0, 199 - y, i & 7);
	}
}
