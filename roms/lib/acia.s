.setcpu   "65C02" 
.debuginfo

.zeropage
.org $0
READ_PTR:       .res 1
WRITE_PTR:      .res 1

.segment "INPUTBUFFER"
INPUT_BUFFER:  .res $100

ACIA        = $5000
ACIA_DATA   = ACIA
ACIA_STATUS = (ACIA+1)
ACIA_CMD    = (ACIA+2)
ACIA_CTRL   = (ACIA+3)

.segment  "ROM"
ACIA_SETUP: lda #$00
            sta ACIA_STATUS           ; reset the chip
            sta READ_PTR              ; setup the circular input buffer
            sta WRITE_PTR
            lda #$1F                  ; N-8-1 19200 BAUD
            sta ACIA_CTRL
            lda #$89                  ; no parity. no echo. no interrupts
            sta ACIA_CMD
            rts

MONRDKEY:
ACIA_RECV:  phx
            jsr BUF_SIZE
            beq @no_key
            jsr READ_BUF
            jsr MONCOUT
            plx
            sec
            rts 
@no_key:    clc
            rts

MONCOUT:
ACIA_SEND:  pha
            sta ACIA_DATA
@send_loop: lda ACIA_STATUS
            txa
            pha
            ldx #$FF
txdelay:    dex 
            bne txdelay
            pla
            tax
            pla
            rts
  
WRITE_BUF:  ldx WRITE_PTR
            sta INPUT_BUFFER, x
            inc WRITE_PTR
            rts

READ_BUF:   ldx READ_PTR
            lda INPUT_BUFFER, x
            inc READ_PTR
            rts

BUF_SIZE:   lda WRITE_PTR
            sec
            sbc READ_PTR
            rts

IRQ:        pha
            phx
            lda ACIA_STATUS           ; assume ACIA is only interrupt
            lda ACIA_DATA
            jsr WRITE_BUF
            plx
            pla
            rti
