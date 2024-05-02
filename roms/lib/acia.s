  .setcpu   "65C02" 
  .segment    "ROM"

  ACIA        = $5000
  ACIA_DATA   = ACIA
  ACIA_STATUS = (ACIA+1)
  ACIA_CMD    = (ACIA+2)
  ACIA_CTRL   = (ACIA+3)

ACIA_SETUP:
  lda #$00
  sta ACIA_STATUS ; reset the chip
  lda #$1F ; N-8-1 19200 BAUD
  sta ACIA_CTRL
  lda #$0B ; no parity. no echo. no interrupts
  sta ACIA_CMD
  rts

ACIA_RECV:
  lda ACIA_STATUS
  and #$08          ; check rx buffer status flag
  beq @no_key
  lda ACIA_DATA
  sec
  rts 
@no_key:
  clc
  rts

MONRDKEY:
  lda ACIA_STATUS
  and #$08
  beq @no_keypressed
  lda ACIA_DATA
  sec
  rts
@no_keypressed:
  clc
  rts

MONCOUT:
ACIA_SEND:
  pha
  sta ACIA_DATA
acia_send_loop:
  lda ACIA_STATUS
  and #$10        ; check transmit buffer status
  beq acia_send_loop
  txa
  pha
  ldx #$FF
txdelay:
  dex 
  bne txdelay
  pla
  tax
  rts
