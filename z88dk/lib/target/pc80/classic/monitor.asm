        IFNDEF CRT_ORG_CODE
            defc CRT_ORG_CODE  = $8A00
        ENDIF

	org CRT_ORG_CODE

;----------------------
; Execution starts here
;----------------------
start:
	call    _main
	jp	$5c66
