  .setcpu   "65C02"
  .debuginfo
  .segment    "ROM"

RESET:
  jsr ACIA_SETUP

  ldy #$00
start_message:
  lda hello, x
  beq end_message
  jsr MONCOUT
  inx
  jmp start_message
end_message:
  lda #$0D
  jsr MONCOUT
  lda #$0A
  jsr MONCOUT
loop:
  jsr MONRDKEY
  bcc loop
  jsr MONCOUT
  cmp #$0D
  bne loop
  lda #$0A
  jsr MONCOUT
  jmp loop

hello: .byte "Hello, world!", $00
long_message: .byte "This is a much longer message that may overrun the output at some point.  But this is a good test of how well the output works.", $00

NMI:
  rti

.include "../../rom/acia.s"
.include "../../rom/vectors.s"
