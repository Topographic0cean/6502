.setcpu   "65C02"
.debuginfo
.include "defines.s"

DECIMAL   = HEAP+12 
CLOCK     = $1000 ; 2 bytes
PCR       = $600C
IER       = $600E

.org START
            lda #$00
            sta CLOCK
            sta CLOCK+1
            sta CLOCK+2
            sta CLOCK+3

clock_loop: jsr MONRDKEY
            bcc @no_key
            inc CLOCK
            bne @no_key
            inc CLOCK+1
            bne @no_key
            inc CLOCK+2
            bne @no_key
            inc CLOCK+3

@no_key:    jsr DISPLAY_HOME
            lda CLOCK
            sta HEAP
            lda CLOCK + 1
            sta HEAP + 1
            lda CLOCK + 2
            sta HEAP + 2
            lda CLOCK + 3
            sta HEAP + 3
            jsr HEXTODEC

            ldx #$00
@output: lda DECIMAL, x
            beq clock_loop
            jsr DISPLAY_PUTC
            inx
            jmp @output
