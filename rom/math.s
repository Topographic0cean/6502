;  math -- expects a numbers to be in HEAP 
;     HEAP is defined outside of this function
.segment    "ROM"


; Divide a 32 bit number in HEAP by a 32 bit number in HEAP+4
; Puts the result in HEAP+8
DIVIDEND    = HEAP
DIVISOR     = HEAP+4
QUOTIENT    = HEAD+8
MODULO      = HEAD+12

DIVIDE32:   pha
            phx
            phy
            ldy     #32         ; 32 bits
            lda     #0
            sta     MODULO
            sta     MODULO+1
            sta     MODULO+2
            sta     MODULO+3
NXT_BIT:    asl     DIVIDEND
            rol     DIVIDEND+1
            rol     DIVIDEND+2
            rol     DIVIDEND+3
            rol     MODULO
            rol     MODULO+1
            rol     MODULO+2
            rol     MODULO+3
            ldx     #$00
            lda     #$08
            sta     ADDDP
            sec
SUBT:      lda     DVDR+8,x   ;Subtract divider from
           sbc     DVDR,x     ; partial dividend and
           sta     MULR,x     ; save
           inx
           dec     ADDDP
           bne     SUBT
           bcc     NXT        ;Branch to do next bit
           inc     DVDQUO     ; if result = or -
           ldx     #$08       ;Put subtractor result
RSULT:     lda     MULR-1,x   ; into partial dividend
           sta     DVDR+7,x
           dex
           bne     RSULT
NXT:       dey
           bne     DO_NXT_BIT
           sec
           lda     DIVXP1     ;Subtract dps and store result
           sbc     DIVXP2
           sta     DIVXP2
           rts