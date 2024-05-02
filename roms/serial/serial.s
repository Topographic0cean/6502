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
  lda #$0D
  jsr ACIA_SEND
  lda #$0A
  jsr ACIA_SEND
loop:
  jsr ACIA_RECV
  bcc loop
  jsr ACIA_SEND
  jmp loop

hello: .byte "Hello, world!", $0D, $00

NMI:
IRQ:
  rti

.include "../lib/acia.s"
.include "../lib/vectors.s"
