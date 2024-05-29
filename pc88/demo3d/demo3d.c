/*
zcc +pc88 -compiler=sdcc -lmath32 --list demo3d.c -o demo3d.bin -create-app
def usr=&h8a00
*/
#include <math.h>
#include <stdlib.h>

char bits[] = {0x80,0x40,0x20,0x10, 0x08,0x04,0x02,0x01};

int vx[] = {-1, 1,-1, 1,-1, 1,-1, 1};
int vy[] = {-1,-1, 1, 1,-1,-1, 1, 1};
int vz[] = {-1,-1,-1,-1, 1, 1, 1, 1};
int l0[] = {0,2,4,6, 0,1,4,5, 0,1,2,3};
int l1[] = {1,3,5,7, 2,3,6,7, 4,5,6,7};

int addr;
char mask;
char port;
int svsp;

void pcls(char plane)
{
	port = 0x5c + plane;
#asm
	ld	a, (_port)
	ld	c, a
	ld	hl, 0
	ld	b, 200

	di
	ld	(_svsp), sp
	ld	sp, 0xc000 + 80 * 200
	out	(c), a
L1:
	rept 40
	push	hl
	endr
	djnz	L1

	out	(0x5f), a
	ld	sp, (_svsp)
	ei
#endasm
}

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
	static int steep, dx, dy, sy, x, y, err, t;

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

void color(int pal, int code)
{
	static int p;

	p  = 0x54 + pal;
	if (code) {
		outp(p, 0x00);
		outp(p, 0x47);
	}
	else {
		outp(p, 0x00);
		outp(p, 0x40);
	}
}

void main(void)
{
	static int px[8], py[8];
	static float t, s, c, x, y, z;
	static int i, a, b;
	static char plane = 0;

//	color(0x32, 0x09);
	color(3, 1);
	for (t = 0; ; t += .1) {
		plane = 1 - plane;
		if (plane) {
			color(2, 0);
			color(1, 1);
		}
		else {
			color(1, 0);
			color(2, 1);
		}
		pcls(plane);
		s = sin(t);
		c = cos(t);
		for (i = 0; i < 8; i++) {
			x = vx[i] * c + vz[i] * s;
			z = vx[i] * s - vz[i] * c + 5;
			px[i] = 320 + x * 600 / z;
			py[i] = 100 - vy[i] * 300 / z;
		}
		for (i = 0; i < 12; i++) {
			a = l0[i];
			b = l1[i];
			pline(px[a], py[a], px[b], py[b], plane);
		}
	}
}
