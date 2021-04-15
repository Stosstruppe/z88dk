//zcc +pc80 -compiler=sdcc --list pset2.c -create-app

typedef unsigned char BYTE;

void init() __naked
{
	__asm
	ld	hl, color
	call	0951h		; color
	ld	bc, 80*256+25
	call	093ah		; width
	ret

color:	db	"0,0,1",0	; 低解像度グラフィック
	__endasm;
}

void pset(BYTE x, BYTE y)
{
	if (x >= 160 || y >= 100) return;
	char *p = (char *)0xf300 + y/4 * 120 + x/2;
	*p |= 0x01 << (x%2 * 4 + y%4);
}

void main()
{
	int i;

	init();
	for (i = 0; i < 100; i++) {
		pset(i, 99 - i);
	}
}
