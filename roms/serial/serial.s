  .setcpu   "65C02"
  .debuginfo
  .segment    "ROM"

RESET:
  lda #$ff
  txs
  jsr ACIA_SETUP
  ldx #$00
start_message:
  lda hello,x
  beq end_message
  jsr ACIA_SEND
  inx
  jmp start_message
end_message:
do_nothing:
  jmp do_nothing

hello: .byte "Hello, world!", $00

NMI:
IRQ:
  rti

.include "../lib/acia.s"
.include "../lib/vectors.s"
