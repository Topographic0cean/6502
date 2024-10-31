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
DISPLAY_CLEAR  	= $00A1C0
DISPLAY_HOME  	= $00A1C6
DISPLAY_INIT  	= $00A168
DISPLAY_LEDS  	= $00A211
DISPLAY_NUM  	= $00A328
DISPLAY_PUTC  	= $00A1CC
DIVIDE32  	= $00A3B4
HEXTODEC  	= $00A275
MONRDKEY  	= $00A0EB
MULT32  	= $00A347
ONE_SEC_DELAY  	= $00A423
VIA_CTS  	= $00A1FF
