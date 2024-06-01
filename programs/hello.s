.setcpu   "65C02"
.debuginfo
.include "defines.s"

.org START
                jsr DISPLAY_CLEAR
                ldy #00
start_message:  lda hello, y
                beq end_message
                jsr DISPLAY_PUTC
                iny
                jmp start_message
end_message:
                jmp end_message

hello: .byte "Hello, world!", $00