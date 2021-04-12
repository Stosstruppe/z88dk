//zcc +pc80 -compiler=sdcc --list sample1.c -create-app

void puts(char *p) __z88dk_fastcall __naked
{
	p;
	__asm
	jp	52edh
	__endasm;
}

char *hoge(int value) __z88dk_fastcall __naked
{
	value;
	__asm
	ld	(0f0a8h), hl	; FAcc
	ld	a, 2		; 整数型
	ld	(0ef45h), a
	jp	2d22h
	__endasm;
}

void main()
{
	int i;
	char *p;

	puts("hello, world\r\n");

	for (i = -10000; i <= 10000; i += 5000) {
		p = hoge(i);
		puts(p);
		puts("\r\n");
	}
}
