//zcc +pc80 -compiler=sdcc --list aalong.c -create-app

void putc(int c) __z88dk_fastcall __naked
{
__asm
	ld	a, l
	rst	18h
	ret
__endasm;
}

long mul(long x, long y)
{
	return (x / 0x1000) * (y / 0x1000);
}

void main()
{
	int i, x, y;
	long a, b, ca, cb, t;

	for (y = -12; y <= 12; y++) {
		for (x = -39; x <= 39; x++) {
			ca = x * (long)(0.0458 * 0x1000000L);
			cb = y * (long)(0.08333 * 0x1000000L);
			a = ca;
			b = cb;
			for (i = 0; i <= 15; i++) {
				t = mul(a, a) - mul(b, b) + ca;
				b = 2 * mul(a, b) + cb;
				a = t;
				if (mul(a, a) + mul(b, b) > 0x4000000L) {
					break;
				}
			}
			putc("0123456789ABCDEF "[i]);
		}
		putc('\r');
		putc('\n');
	}
}
