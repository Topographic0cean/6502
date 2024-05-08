
.segment    "ROM"

VALUE = HEAP          ; 2 bytes
MOD10 = VALUE + 2     ; 2 bytes
DECSTR = MOD10 + 2    ; 6 bytes
  
HEXTODEC:
  ; initialize remainder to 0
  lda #0
  sta DECSTR
hextodec_init:
  lda #0
  sta MOD10
  sta MOD10 + 1
  clc
  ldx #16
hextodec_loop:
  ; rotate quotient and remainder
  rol VALUE
  rol VALUE + 1
  rol MOD10
  rol MOD10 + 1
  ; a,y = dividend - divisor
  sec 
  lda MOD10
  sbc #10
  tay ; save low byte in y
  lda MOD10 + 1
  sbc #0
  bcc hextodec_ignore ; branch if dividend < divisor
  sty MOD10
  sta MOD10 + 1
hextodec_ignore:
  dex
  bne hextodec_loop
  rol VALUE
  rol VALUE + 1
  lda MOD10
  clc
  adc #$30   ; "0"
  jsr hextodec_push
  lda VALUE
  ora VALUE + 1
  bne hextodec_init
  rts

hextodec_push:
  ; add char in a register to beginning of string
  ldy #0
  pha
hextodec_p_loop:
  lda DECSTR, y
  phx 
  sta DECSTR, y
  iny
  plx
  bne hextodec_p_loop
  pla
  sta DECSTR, y
  rts

