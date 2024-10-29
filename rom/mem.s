;   Memory locations used by the ROM.   Put them all here so we can keep track
;   of what is where.
;
; RAM address space
;
; Zero Page
; $00 - $0B     ; usable
; $0C - $FF     ; MSBASIC usage start

; $0100 - $01FF     stack 

; $0200 - $02FF     unknown 

; $0300 - $03FF     Input buffer for serial line


READ_PTR    = $00       ; used by the keyboard buffer to store pointers to the 
WRITE_PTR   = $01       ; character buffer

PORT        = $02       ; keep track of what PORTA should be.  Since it is used by different
                        ; functions.  We do not expect them to know what each is doing.

XAML        = $03                            ; last opened location low
XAMH        = $04                            ; last opened location high
STL         = $05                            ; store address low
STH         = $06                            ; store address high
L           = $07                            ; Hex value parsing Low
H           = $08                            ; Hex value parsing High
YSAV        = $09                            ; Used to see if hex value is given
MODE        = $0A                            ; $00=XAM, $7F=STOR, $AE=BLOCK XAM

INPUT_BUFFR = $0300
INPUTBUF    = $0200
HEAP        = $0400

ACIA        = $5000
LCD         = $6000
