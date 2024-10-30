.setcpu   "65C02"
.debuginfo
.include "../../rom/include/defines.s"

LED         = $5C
DECIMAL     = HEAP+12 

.org START
                    jsr DISPLAY_CLEAR 
                    lda #$00
                    sta LED
                    sta HEAP
                    sta HEAP+1
                    sta HEAP+2
                    sta HEAP+3
@loop:
                    jsr DISPLAY_HOME
                    lda LED
                    sta HEAP
                    jsr HEXTODEC
                    ldy #$00
@output:
                    lda DECIMAL, y
                    beq @done
                    jsr DISPLAY_PUTC
                    iny
                    jmp @output
@done:
                    lda LED
                    jsr DISPLAY_LEDS
                    jsr ONE_SEC_DELAY
                    inc LED
                    bne @loop
@stop:
                    jmp @stop
