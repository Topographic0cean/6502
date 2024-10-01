;
; Increment a count on every keypress and display it on
; the LCD.
;

.setcpu   "65C02"
.debuginfo
.include "defines.s"

DECIMAL   = HEAP+12 
COUNT     = $1000 ; 2 bytes
PCR       = $600C
IER       = $600E

.org START
            lda #$00
            sta COUNT
            sta COUNT+1
            sta COUNT+2
            sta COUNT+3
            jsr DISPLAY_CLEAR

clock_loop: jsr MONRDKEY
            bcc @no_key
            inc COUNT
            bne @no_key
            inc COUNT+1
            bne @no_key
            inc COUNT+2
            bne @no_key
            inc COUNT+3

@no_key:    jsr DISPLAY_HOME
            lda COUNT
            sta HEAP
            lda COUNT + 1
            sta HEAP + 1
            lda COUNT + 2
            sta HEAP + 2
            lda COUNT + 3
            sta HEAP + 3
            jsr HEXTODEC

            ldx #$00
@output: lda DECIMAL, x
            beq clock_loop
            jsr DISPLAY_PUTC
            inx
            jmp @output
