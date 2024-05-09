;  hex2dec -- expects a 16 bit number to be in H2DRAM 
;     H2DRAM is defined outside of this function and needs to  10 bytes
;     Puts the decimal string representation in H2DRAM+4
.segment    "ROM"

VALUE = H2DRAM        ; 2 bytes
MOD10 = VALUE + 2     ; 2 bytes
DECSTR = MOD10 + 2    ; 6 bytes
  
HEXTODEC:
  pha
  phx
  phy
  ; initialize remainder to 0
  lda #$00
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
  ply
  plx 
  pla
  rts

hextodec_push:
  ; add char in a register to beginning of string
  phx
  phy
  ldx #$00
@loop:
  pha
  lda DECSTR, x
  tay
  pla
  sta DECSTR, x
  inx
  tya
  beq @done
  jmp @loop 
@done:
  sta DECSTR, x
  ply
  plx
  rts
