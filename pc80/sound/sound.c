//zcc +pc80 -compiler=sdcc --list sound.c -create-app

//#define BYTE unsigned char
typedef unsigned char BYTE;
typedef unsigned short WORD;

typedef struct {
	BYTE port;
	BYTE index;
	BYTE tick;
} SEQ;

//	C     C#    D     D#    E     F     F#    G     G#    A     A#    B
const WORD tones[] = {
	    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,64793, // O1
	61156,57724,54484,51426,48540,45815,43244,40817,38526,36364,34323,32396, // O2
	30578,28862,27242,25713,24270,22908,21622,20408,19263,18182,17161,16198, // O3
	15289,14431,13621,12857,12135,11454,10811,10204, 9631, 9091, 8581, 8099, // O4
	 7645, 7215, 6810, 6428, 6067, 5727, 5405, 5102, 4816, 4545, 4290, 4050, // O5
	 3822, 3608, 3405, 3214, 3034, 2863, 2703, 2551, 2408, 2273, 2145, 2025, // O6
};

const BYTE data0[] = {
	53,24, 0,16, 48,8, 53,8, 57,8, 60,8, 57,8, 0,8, 53,8,
	55,8, 0,8, 55,8, 55,8, 0,8, 50,8+8, 0,8, 55,8, 53,8, 0,8, 52,8,
	53,24, 0,16, 48,8, 53,8, 57,8, 60,8, 57,8, 0,8, 53,8,
	54,8, 0,8, 54,8, 54,8, 0,8, 53,8+48, 0xff
};
const BYTE data1[] = {
	45,24, 0,16, 45,8, 45,8, 48,8, 53,8, 48,8, 0,8, 45,8,
	46,8, 0,8, 46,8, 46,8, 0,8, 46,8+8, 0,8, 46,8, 46,8, 0,8, 46,8,
	45,24, 0,16, 45,8, 45,8, 45,8, 45,8, 45,8, 0,8, 45,8,
	46,8, 0,8, 46,8, 46,8, 0,8, 45,8+48, 0xff
};
const BYTE data2[] = {
	29,8, 29,8, 29,8, 29,8, 0,16, 29,8, 29,8, 29,8, 29,8, 0,16,
	29,8, 29,8, 29,8, 29,8, 0,16, 29,8, 29,8, 29,8, 29,8, 0,16,
	29,8, 29,8, 29,8, 29,8, 0,16, 29,8, 29,8, 29,8, 29,8, 0,16,
	29,8, 29,8, 29,8, 29,8, 0,8, 29,8, 0,48, 0xff
};
const BYTE *data[3] = { data0, data1, data2 };

void outp(BYTE port, BYTE value) __naked
{
__asm
	ld	hl, 2
	add	hl, sp
	ld	c, (hl)
	inc	hl
	ld	a, (hl)
	out	(c), a
	ret
__endasm;
}

void vsync() __naked
{
__asm
vsync1:
	in	a, (40h)
	and	20h
	jp	nz, vsync1
vsync2:
	in	a, (40h)
	and	20h
	jp	z, vsync2
	ret
__endasm;
}

SEQ seq[3];

void init()
{
	int i;
	SEQ *pSeq;

	for (i = 0; i < 3; i++) {
		pSeq = seq + i;
		pSeq->port = 0x0c + i;
		pSeq->index = 0;
		pSeq->tick = 1;
	}
	outp(0x0f, 0x36);	// ch0
	outp(0x0f, 0x76);	// ch1
	outp(0x0f, 0xb6);	// ch2
	outp(0x02, 0xc8);
}

void play(int ch)
{
	BYTE p, i;
	WORD w;
	SEQ *pSeq = &seq[ch];
	const BYTE *pData;

	p = pSeq->port;
	if (--pSeq->tick) {
		if (pSeq->tick < 2) {
			outp(p, 0);
			outp(p, 0);
		}
		return;
	}

	pData = data[ch];
	i = pSeq->index;
	if (pData[i] == 0xff) {
		i = 0;
	}

	w = tones[pData[i]];
	outp(p, w % 256);
	outp(p, w / 256);

	pSeq->tick = pData[++i];
	pSeq->index = ++i;
}

void main()
{
	init();
	for (;;) {
		vsync();
		play(0);
		play(1);
		play(2);
	}
}
