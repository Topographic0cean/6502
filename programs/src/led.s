.setcpu   "65C02"
.debuginfo
.include "../include/defines.s"

.org START
                    jsr DISPLAY_CLEAR 
                    lda #$00
@loop:
                    jsr DISPLAY_LEDS
                    adc #$01
                    jsr ONE_SEC_DELAY
                    jmp @loop
