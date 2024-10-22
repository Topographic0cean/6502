;  math -- expects numbers to be in HEAP 
;     HEAP is defined outside of this function
.segment    "ROM"



; Multiply two 32 bit numbers
MULT32_MULTC     = HEAP    ; multiplicand
MULT32_MULTP     = HEAP+4  ; multiplier
MULT32_RESULT    = HEAP+8  ; result of multiplication

MULT32:  
            lda #$00
            sta MULT32_RESULT
            sta MULT32_RESULT+1
            sta MULT32_RESULT+2
            sta MULT32_RESULT+3
@MULT32_ADD:
            jsr MULT32_TEST_MULTP       ; check if MULTP is zero
            beq @MULT32_DONE
            CLC
            LDA MULT32_MULTC
            ADC MULT32_RESULT
            STA MULT32_RESULT
            LDA MULT32_MULTC+1
            ADC MULT32_RESULT+1
            STA MULT32_RESULT+1
            LDA MULT32_MULTC+2
            ADC MULT32_RESULT+2
            STA MULT32_RESULT+2
            LDA MULT32_MULTC+3
            ADC MULT32_RESULT+3
            STA MULT32_RESULT+3
            JSR MULT32_DEC_MULTP
            jmp @MULT32_ADD
@MULT32_DONE:
            rts

MULT32_TEST_MULTP:
            lda MULT32_MULTP
            ora MULT32_MULTP+1
            ora MULT32_MULTP+2
            ora MULT32_MULTP+3
            rts

MULT32_DEC_MULTP:
            lda MULT32_MULTP
            bne @MULT32_DEC_DONE
            lda MULT32_MULTP+1
            bne @MULT32_DEC_DONE_1
            lda MULT32_MULTP+2
            bne @MULT32_DEC_DONE_2
            lda MULT32_MULTP+3
            beq @MULT32_DEC_ALL_DONE
            dec MULT32_MULTP+3
@MULT32_DEC_DONE_2:
            dec MULT32_MULTP+2
@MULT32_DEC_DONE_1:
            dec MULT32_MULTP+1
@MULT32_DEC_DONE:
            dec MULT32_MULTP
@MULT32_DEC_ALL_DONE:
            rts




; Divide a 32 bit number in HEAP by a 32 bit number in HEAP+4
; Puts the result in HEAP+8
;DIVIDEND    = HEAP
;DIVISOR     = HEAP+4
;QUOTIENT    = HEAP+8
;MODULO      = HEAP+12
;
;DIVIDE32:   pha
;            phx
;            phy
;            ldy     #32         ; 32 bits
;            lda     #0
;            sta     MODULO
;            sta     MODULO+1
;            sta     MODULO+2
;            sta     MODULO+3
;NXT_BIT:    asl     DIVIDEND
;            rol     DIVIDEND+1
;            rol     DIVIDEND+2
;            rol     DIVIDEND+3
;            rol     MODULO
;            rol     MODULO+1
;            rol     MODULO+2
;            rol     MODULO+3
;            ldx     #$00
;            lda     #$08
;            sta     ADDDP
;            sec
;SUBT:      lda     DVDR+8,x   ;Subtract divider from
;           sbc     DVDR,x     ; partial dividend and
;           sta     MULR,x     ; save
;           inx
;           dec     ADDDP
;           bne     SUBT
;           bcc     NXT        ;Branch to do next bit
;           inc     DVDQUO     ; if result = or -
;           ldx     #$08       ;Put subtractor result
;RSULT:     lda     MULR-1,x   ; into partial dividend
;           sta     DVDR+7,x
;           dex
;           bne     RSULT
;NXT:       dey
;           bne     DO_NXT_BIT
;           sec
;           lda     DIVXP1     ;Subtract dps and store result
;           sbc     DIVXP2
;           sta     DIVXP2
;           rts
