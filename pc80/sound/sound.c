//zcc +pc80 -compiler=sdcc --list sound.c -create-app

//#define BYTE unsigned char
typedef unsigned char BYTE;
typedef unsigned short WORD;

typedef struct {
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

const BYTE data[] = {
	36,15, 40,15, 43,15, 48,15, 0xff
};

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

SEQ seq;

void init()
{
	seq.index = 0;
	seq.tick = 0;

	outp(0x0f, 0x36);	// ch0
//	outp(0x02, 0xc8);
	outp(0x02, 0x08);	// ch0
}

void play()
{
	BYTE i, t;
	WORD w;

	if (seq.tick) {
		seq.tick--;
		return;
	}

	i = seq.index;
	t = data[i];
	if (t == 0xff) {
		i = 0;
		t = data[i];
	}

	w = tones[t];
	outp(0x0c, w % 256);	// ch0
	outp(0x0c, w / 256);	// ch0

	seq.tick = data[++i];
	seq.index = ++i;
}

void main()
{
	init();
	for (;;) {
		vsync();
		play();
	}
}
