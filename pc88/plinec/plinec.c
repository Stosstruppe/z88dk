/*
zcc +pc88 -compiler=sdcc --list plinec.c -o plinec.bin -create-app
def usr=&h8a00
*/
#include <stdlib.h>

char bits[] = {0x80,0x40,0x20,0x10, 0x08,0x04,0x02,0x01};

int addr;
char mask;
char port;

void ppset(int x, int y)
{
	addr = 0xc000 + 80 * y + (x >> 3);
	mask = bits[x & 0x7];
#asm
	ld	hl, (_addr)
	ld	a, (_port)
	ld	c, a
	ld	a, (_mask)

	di
	out	(c), a
	or	(hl)
	ld	(hl), a
	out	(0x5f), a
	ei
#endasm
}

void pline(int x0, int y0, int x1, int y1, char plane)
{
	int steep, dx, dy, sy, x, y, err, t;

	port = 0x5c + plane;

	steep = abs(y1 - y0) > abs(x1 - x0);
	if (steep) {
		t = x0; x0 = y0; y0 = t;
		t = x1; x1 = y1; y1 = t;
	}
	if (x0 > x1) {
		t = x0; x0 = x1; x1 = t;
		t = y0; y0 = y1; y1 = t;
	}
	dx = x1 - x0;
	dy = abs(y1 - y0);
	err = dx / 2;
	sy = (y0 < y1) ? 1 : -1;
	y = y0;
	for (x = x0; x <= x1; x++) {
		if (steep) ppset(y, x); else ppset(x, y);
		err -= dy;
		if (err < 0) {
			y += sy;
			err += dx;
		}
	}
}

int fnr(int x)
{
	return rand() % x;
}

void main(void)
{
	int i;

	for (i = 0; i < 100; i++) {
		pline(fnr(640), fnr(200), fnr(640), fnr(200), fnr(3));
	}
}
