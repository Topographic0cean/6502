;  hex2dec -- expects a 16 bit number to be in HEAP 
;     HEAP is defined outside of this function and needs to  10 bytes
;     Puts the decimal string representation in HEAP+4
.segment    "ROM"

VALUE     = HEAP          ; 4 bytes
MOD10     = VALUE + 4     ; 4 bytes
DIVSAVE   = MOD10 + 4     ;
DECSTR    = DIVSAVE + 4    ; 12 bytes
  
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
  sta MOD10 + 2
  sta MOD10 + 3
  clc
  ldx #32
hextodec_loop:
  ; rotate quotient and remainder
  rol VALUE
  rol VALUE + 1
  rol VALUE + 2
  rol VALUE + 3
  rol MOD10
  rol MOD10 + 1
  rol MOD10 + 2
  rol MOD10 + 3
  ; a,y = dividend - divisor
  sec 
  lda MOD10
  sbc #10
  sta DIVSAVE
  lda MOD10 + 1
  sbc #0
  sta DIVSAVE + 1
  lda MOD10 + 2
  sbc #0
  sta DIVSAVE + 2
  lda MOD10 + 3
  sbc #0
  sta DIVSAVE + 3
  bcc hextodec_ignore ; branch if dividend < divisor
  lda DIVSAVE
  sta MOD10
  lda DIVSAVE + 1
  sta MOD10 + 1
  lda DIVSAVE + 2
  sta MOD10 + 2
  lda DIVSAVE + 3
  sta MOD10 + 3
hextodec_ignore:
  dex
  bne hextodec_loop
  rol VALUE
  rol VALUE + 1
  rol VALUE + 2
  rol VALUE + 3
  lda MOD10
  clc
  adc #$30   ; "0"
  jsr hextodec_push
  lda VALUE
  ora VALUE + 1
  ora VALUE + 2
  ora VALUE + 3
  beq @done
  jmp hextodec_init
@done:
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
