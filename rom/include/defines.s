;   Memory locations used by the ROM.   Put them all here so we can keep track
;   of what is where.
;
; RAM address space
;
; Zero Page
READ_PTR        = $00       ; used by the keyboard buffer to store pointers to the 
WRITE_PTR       = $01       ; character buffer
PORT            = $02       ; keep track of what PORTA should be.  Since it is used by different
                            ; functions.  We do not expect them to know what each is doing.
; Used by Wozmon
XAML            = $03       ; last opened location low
XAMH            = $04       ; last opened location high
STL             = $05       ; store address low
STH             = $06       ; store address high
L               = $07       ; Hex value parsing Low
H               = $08       ; Hex value parsing High
YSAV            = $09       ; Used to see if hex value is given
MODE            = $0A       ; $00=XAM, $7F=STOR, $AE=BLOCK XAM
ZP_MSBASIC      = $0C       ; MSBASIC usage start until end of ZP

.ifndef STACK
STACK           = $0100     ; 256 bytes
.endif
INPUTBUF        = $0200     ; Used by ACIA to store key presses
INPUT_BUFFR     = $0300
SER_INPUT_BUF   = $0300     ; Input buffer for serial line
HEAP            = $0400     ; 256 bytes of general storage area used by ROM
STORAGE         = $0500     ; $0500 - $0FFF General storage area for RAM programs

START           = $1000     ; Good place to put the RAM program

ACIA            = $5000
LCD             = $6000

START_ROM       = $8000
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
