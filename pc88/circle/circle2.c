/*
zcc +pc88 circle2.c -create-app -subtype=disk
*/
#include <stdlib.h>

void pset(int x, int y)
{
	char *p = 0xc000 + (y*80) + (x>>3);
	*p = 0x80 >> (x&7);
}

void ellipse(int x0, int y0, int x1, int y1)
{
	long a = abs(x1 - x0);
	long b = abs(y1 - y0);
	long b1 = b & 1;
	long dx = 4L * (1 - a) * b * b;
	long dy = 4L * (b1 + 1) * a * a;
	long err = dx + dy + b1 * a * a;

	if (x0 > x1) {
		x0 = x1;
		x1 += a;
	}
	if (y0 > y1) y0 = y1;
	y0 += (b + 1) / 2;
	y1 = y0 - b1;
	a *= 8 * a;
	b1 = 8 * b * b;

	do {
		pset(x1, y0);
		pset(x0, y0);
		pset(x0, y1);
		pset(x1, y1);
		long e2 = 2 * err;
		if (e2 <= dy) {
			y0++;
			y1--;
			err += dy += a;
		}
		if (e2 >= dx || 2 * err > dy) {
			x0++;
			x1--;
			err += dx += b1;
		}
	} while (x0 <= x1);

	while (y0 - y1 < b) {
		pset(x0 - 1, y0);
		pset(x1 + 1, y0++);
		pset(x0 - 1, y1);
		pset(x1 + 1, y1--);
	}
}

void main(void)
{
	asm("di");
	outp(0x32, 0xd9);	// ALU
	outp(0x35, 0x80);	// GVRAM
	outp(0x34, 6);		// GRB

	int a = 310, b = 90;
	ellipse(320 - a, 100 - b, 320 + a, 100 + b);

	outp(0x32, 0xa9);
	asm("ei");
}
