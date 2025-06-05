/*
zcc +pc88 circle1.c -create-app -subtype=disk
*/
#include <stdlib.h>

void pset(int x, int y)
{
	char *p = 0xc000 + (y*80) + (x>>3);
	*p = 0x80 >> (x&7);
}

void circle(int xm, int ym, int r)
{
	int x = -r;
	int y = 0;
	int err = 2 - 2 * r;
	do {
		pset(xm - x, ym + y);
		pset(xm - y, ym - x);
		pset(xm + x, ym - y);
		pset(xm + y, ym + x);
		r = err;
		if (r <= y) err += ++y * 2 + 1;
		if (r > x || err > y) err += ++x * 2 + 1;
	} while (x < 0);
}

void main(void)
{
	asm("di");
	outp(0x32, 0xd9);	// ALU
	outp(0x35, 0x80);	// GVRAM
	outp(0x34, 6);		// GRB
	circle(320, 100, 90);
	outp(0x32, 0xa9);
	asm("ei");
}
