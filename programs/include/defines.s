; RAM address space

; Zero Page
; $00 - $01     ; 2 bytes for the input buffer
; $02           ; 1 byte  for the display
; $0C - $FF     ; MSBASIC usage start

; $0100 - $01FF     stack 

; $0200 - $02FF     unknown 

; $0300 - $03FF     Input buffer for serial line

HEAP                = $0400     ; 256 bytes of general storage area used by ROM

STORAGE             = $0500     ; $0500 - $1FFF General storage area for RAM programs

START               = $2000     ; Good place to put the RAM program
MONRDKEY  	= $00A0EB
DISPLAY_CLEAR  	= $00A183
DISPLAY_HOME  	= $00A189
DISPLAY_PUTC  	= $00A18F
VIA_CTS  	= $00A1C2
HEXTODEC  	= $00A22B
MULT32  	= $00A2DE
ONE_SEC_DELAY  	= $00A34B
