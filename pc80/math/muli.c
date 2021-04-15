//zcc +pc80 -compiler=sdcc --list muli.c -create-app

void putch(char c) __z88dk_fastcall __naked
{
	c;
	__asm
	ld	a, l
	rst	18h
	ret
	__endasm;
}

int muli(int x, int y) __naked
{
	x;
	y;
	__asm
	ld	hl, 2
	add	hl, sp
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a
	jp	28fdh		; ®”æZ.
	__endasm;
}

void printi(short v) __z88dk_fastcall __naked
{
	v;
	__asm
	jp	2d13h		; HL‚ğƒvƒŠƒ“ƒg
	__endasm;
}

void main()
{
	int i, j, k;

	for (i = 0; i <= 10; i++) {
		for (j = 0; j <= 10; j++) {
			k = muli(i, j);
			printi(k);
			putch(' ');
		}
		putch('\r');
		putch('\n');
	}
}
