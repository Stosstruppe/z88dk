//zcc +pc80 -compiler=sdcc --list aashort.c -create-app

#define BASE 0x200

void putc(int c) __z88dk_fastcall __naked
{
__asm
	ld	a, l
	rst	18h
	ret
__endasm;
}

short mul(short x, short y)
{
	return (short)((long)x * y / BASE);
}

void main()
{
	int i, x, y;
	short a, b, ca, cb, t;

	for (y = -12; y <= 12; y++) {
		for (x = -39; x <= 39; x++) {
			ca = x * (short)(0.0458 * BASE);
			cb = y * (short)(0.08333 * BASE);
			a = ca;
			b = cb;
			for (i = 0; i <= 15; i++) {
				t = mul(a, a) - mul(b, b) + ca;
				b = 2 * mul(a, b) + cb;
				a = t;
				if (mul(a, a) + mul(b, b) > (4 * BASE)) {
					break;
				}
			}
			putc("0123456789ABCDEF "[i]);
		}
		putc('\r');
		putc('\n');
	}
}
