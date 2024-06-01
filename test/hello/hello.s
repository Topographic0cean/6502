.setcpu   "65C02"
.debuginfo
.segment    "ROM"

DISPLAY   = $0000

RESET:
  jsr DISPLAY_SETUP
  jsr DISPLAY_CLEAR
  ldy #00
start_message:
  lda hello, y
  beq end_message
  jsr DISPLAY_PUTC
  iny
  jmp start_message
end_message:
do_nothing:
  jmp do_nothing

hello: .byte "Hello, world!", $00

NMI:
IRQ:
  rti

.include "../lib/display.s"
.include "../lib/vectors.s"
