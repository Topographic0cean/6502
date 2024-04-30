  .setcpu   "65C02"
  .debuginfo

  .segment    "BIOS"

  STACK       = $0100 ; 256 byte stack
  INPUTBUF    = $0200 ; Wozmon input buffer
  HEAP        = $0300
  ACIA        = $5000
  ACIA_DATA   = ACIA
  ACIA_STATUS = (ACIA+1)
  ACIA_CMD    = (ACIA+2)
  ACIA_CTRL   = (ACIA+3)

acia_setup:
  lda #$00
  sta ACIA_STATUS ; reset the chip
  lda #$1F ; N-8-1 19200 BAUD
  sta ACIA_CTRL
  lda #$0b ; no parity. no echo. no interrupts
  rts

acia_recv:
  jsr acia_delay
  lda ACIA_STATUS
  and #$08          ; check rx buffer status flag
  beq acia_recv
  lda ACIA_DATA
  rts

acia_send:
  pha
  sta ACIA_DATA
acia_send_loop:
  lda ACIA_STATUS
  and #$10        ; check transmit buffer status
  beq acia_send_loop
  jsr acia_delay
  pla
  rts

acia_delay:
  phx
  ldx #100
acia_delay_loop:
  dex
  bne acia_delay_loop
  plx
  rts

  .include    "wozmon.s"
  .include    "vectors.s"



