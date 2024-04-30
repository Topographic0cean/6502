  .setcpu   "65C02"
  .debuginfo
  .segment    "ROM"

RESET:
  lda #$ff
  txs
  jsr DISPLAY_SETUP
  jsr DISPLAY_CLEAR
start_message:
  lda hello,x
  beq end_message
  jsr DISPLAY_PUTC
  inx
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
