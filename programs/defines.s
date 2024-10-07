; RAM address space

; Zero Page
; $00 - $01     ; 2 bytes for the input buffer
; $02           ; 1 byte  for the display
; $0C - $FF     ; MSBASIC usage start

; $0100 - $01FF ; stack 

; 

; $0300 - $03FF ; Input buffer for serial line
HEAP                = $0400     ; 256 bytes of general storage area used by ROM

STORAGE             = $0500     ; $0500 - $1FFF General storage area for RAM programs

START               = $2000     ; Good place to put the RAM program

MONRDKEY            = $00A0EB     ; Check for keypress.

DISPLAY_CLEAR       = $00A183     ; Call to clear the LCD
DISPLAY_HOME        = $00A189     ; Call to move LCD cursor to beginning
DISPLAY_PUTC        = $00A18F     ; Call to add the character in accumlator to LCD

VIA_CTS             = $00A1C2     ; Sets serial CTS from accumulator

HEXTODEC            = $00A22B     ; Call to convert 16 bit hexidecimal number stored in HEAP to  
                                ; decimal string.  String will start at HEAP+12 and be null terminated.