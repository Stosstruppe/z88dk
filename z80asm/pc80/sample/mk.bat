@set target=mul16b

z80asm -b -l %target%
@if errorlevel 1 goto end

z88dk-appmake +pc88 --org 0xd000 -b %target%.bin
@if errorlevel 1 goto end

:end
