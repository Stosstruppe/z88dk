@set SRC=%1.z80s
@set BIN=test.z80

z80asm %SRC% %bin%
@if errorlevel 1 goto END

z80emu %BIN%

:END
