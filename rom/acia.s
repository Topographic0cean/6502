.setcpu   "65C02" 
.debuginfo
.segment  "ROM"

READ_PTR      = $00
WRITE_PTR     = $01

INPUT_BUFFER = $0300

ACIA        = $5000
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
            lda INPUT_BUFFER, x
            inc READ_PTR
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

IRQ:        pha
            phx
            lda ACIA_STATUS           ; assume ACIA is only interrupt
            lda ACIA_DATA
WRITE_BUF:  ldx WRITE_PTR
            sta INPUT_BUFFER, x
            inc WRITE_PTR
            plx
            pla
            rti
