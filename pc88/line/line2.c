/*
zcc +pc88 line2.c -create-app
zcc +pc88 line2.c -create-app -subtype=disk
*/
#include <stdlib.h>

typedef unsigned char BYTE;

BYTE *addr;
BYTE mask;
int x0, y0, x1, y1;
int dx, dy, xs, ys;
int err, cnt;

void step_x(void)
{
	if (xs) {
		mask <<= 1;
		if (mask == 0) {
			mask = 0x01;
			addr--;
		}
	} else {
		mask >>= 1;
		if (mask == 0) {
			mask = 0x80;
			addr++;
		}
	}
}

void step_y(void)
{
	addr += ys;
}

void line_xmajor(void)
{
	err = dx / 2;
	for (cnt = dx; cnt >= 0; cnt--) {
		*addr |= mask;
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
		*addr |= mask;
		step_y();
		err -= dx;
		if (err < 0) {
			err += dy;
			step_x();
		}
	}
}

void line(int a, int b, int c, int d)
{
	x0 = a; y0 = b; x1 = c; y1 = d;
	dx = abs(x1 - x0);
	dy = abs(y1 - y0);
	xs = (x0 <= x1) ? 0 : 1;
	ys = (y0 <= y1) ? 80 : -80;
	addr = (BYTE *)0xc000 + 80 * y0 + x0 / 8;
	mask = 0x80 >> (x0 % 8);

	asm("di");
	if (dx >= dy) {
		M_OUTP(0x5d, 0);
		line_xmajor();
	} else {
		M_OUTP(0x5e, 0);
		line_ymajor();
	}
	M_OUTP(0x5f, 0);
	asm("ei");
}

void main(void)
{
	static int i;
	for (i = 0; i < 640; i += 2) {
		line(i, 0, 639 - i, 199);
	}
	for (i = 0; i < 200; i += 2) {
		line(639, i, 0, 199 - i);
	}
}
