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
NXT_BIT:    asl    DVDQUO
           rol     DVDQUO+1
           rol     DVDQUO+2
           rol     DVDQUO+3
           rol     DVDQUO+4
           rol     DVDQUO+5
           rol     DVDQUO+6
           rol     DVDQUO+7
           rol     DVDR+8
           rol     DVDR+9
           rol     DVDR+$a
           rol     DVDR+$b
           rol     DVDR+$c
           rol     DVDR+$d
           rol     DVDR+$e
           rol     DVDR+$f
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