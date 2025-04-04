.setcpu   "65C02" 
.debuginfo
.segment  "ROM"




ACIA_DATA   = ACIA
ACIA_STATUS = (ACIA+1)
ACIA_CMD    = (ACIA+2)
ACIA_CTRL   = (ACIA+3)

ACIA_SETUP: lda #$00
            sta ACIA_STATUS           ; reset the chip
            sta READ_PTR              ; setup the circular input buffer
            sta WRITE_PTR
            lda #$1F                  ; N-8-1 19200 BAUD
            sta ACIA_CTRL
            lda #$89                  ; no parity. no echo. no interrupts
            sta ACIA_CMD
            rts

MONRDKEY:   jsr BUF_SIZE
            beq @no_key
            phx
            ldx READ_PTR
            lda ACAIA_BUFFER, x
            inc READ_PTR
            pha
            jsr BUF_SIZE
            cmp #$B0
            bcs @FULLISH
            lda #$01
            jsr VIA_CTS
@FULLISH:   pla
            plx
            sec
            rts 
@no_key:    clc
            rts

MONCOUT:    pha
            sta ACIA_DATA
            phx
            ldx #$FF
txdelay:    dex 
            bne txdelay
            plx 
            pla
            rts
  
BUF_SIZE:   lda WRITE_PTR
            sec
            sbc READ_PTR
            rts

ACIA_READ:
            pha
            phx
            lda ACIA_STATUS           ; assume ACIA is only interrupt
            lda ACIA_DATA
WRITE_BUF:  ldx WRITE_PTR
            sta ACAIA_BUFFER, x
            inc WRITE_PTR
            jsr BUF_SIZE
            cmp #$F0
            bcc @NOT_FULL
            lda #$00
            jsr VIA_CTS
@NOT_FULL:  plx
            pla
            rts
