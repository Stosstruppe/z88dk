	org	$d000

	ld	hl, msg
	call	$52ed		; puts
	jp	$5c66		; monitor

msg:	db	"hello, world\r\n", 0
