/*
zcc +pc88 circle5.c -create-app -subtype=disk
*/
#include <stdlib.h>

void pset(int x, int y)
{
	char *p = 0xc000 + (y * 80) + (x >> 3);
	*p = 0x80 >> (x & 7);
}

void circle(int cx, int cy, int ca, int color)
{
	outp(0x34, color);

	int px = 0;
	int py = ca / 2;
	int err = 0;

	while (px <= ca && py >= 0) {
		pset(cx + px, cy + py);
		pset(cx + px, cy - py);
		pset(cx - px, cy - py);
		pset(cx - px, cy + py);

		int ex = (2 * px + 1);
		int ey = (-2 * py + 1) * 4;
		err += ex + ey;
		if (err < 0) {
			px++;
			int e1 = err - ey;
			if (err + e1 < 0) {
				err = e1;
			} else {
				py--;
			}
		} else {
			py--;
			int e3 = err - ex;
			if (err + e3 < 0) {
				px++;
			} else {
				err = e3;
			}
		}
	}
}

void main(void)
{
	asm("di");
	outp(0x32, 0xe9);	// ALU
	outp(0x35, 0x80);	// gvram

	for (int i = 0; i < 200; i += 3) {
		circle(320, 100, i, i%7 + 1);
	}

	outp(0x32, 0xa9);
	asm("ei");
}
