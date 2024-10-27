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
; Puts the result in HEAP
DIVIDE32_DIVIDEND    = HEAP         ; 32 bit numerator
DIVIDE32_DIVISOR     = HEAP+4       ; 16 bit divisor
DIVIDE32_REM         = HEAP+8       ; 32 bit remainder 
DIVIDE32_SAVE        = HEAP+20      ; temp area

DIVIDE32:
            LDA #0              ;Initialize REM to 0
            STA DIVIDE32_REM
            STA DIVIDE32_REM+1
            STA DIVIDE32_REM+2
            STA DIVIDE32_REM+3

            LDX #32             ;There are 32 bits 

@DIVIDE32_LOOP:
            ASL DIVIDE32_DIVIDEND       ;Shift hi bit of numerator into remainder
            ROL DIVIDE32_DIVIDEND+1     ;(vacating the lo bit, which will be used for the quotient)
            ROL DIVIDE32_DIVIDEND+2     
            ROL DIVIDE32_DIVIDEND+3     
            ROL DIVIDE32_REM
            ROL DIVIDE32_REM+1
            ROL DIVIDE32_REM+2
            ROL DIVIDE32_REM+3
            LDA DIVIDE32_REM
            SEC                 ;Trial subtraction
            SBC DIVIDE32_DIVISOR
            STA DIVIDE32_SAVE
            LDA DIVIDE32_REM+1
            SBC DIVIDE32_DIVISOR+1
            STA DIVIDE32_SAVE+1
            LDA DIVIDE32_REM+2
            SBC DIVIDE32_DIVISOR+2
            STA DIVIDE32_SAVE+2
            LDA DIVIDE32_REM+3
            SBC DIVIDE32_DIVISOR+3
            STA DIVIDE32_SAVE+3
            BCC @subfail    ; Did subtraction succeed?
            LDA DIVIDE32_SAVE
            STA DIVIDE32_REM
            LDA DIVIDE32_SAVE+1
            STA DIVIDE32_REM+1
            LDA DIVIDE32_SAVE+2
            STA DIVIDE32_REM+2
            LDA DIVIDE32_SAVE+3
            STA DIVIDE32_REM+3
            CLC
            INC DIVIDE32_DIVIDEND   ; and record a 1 in the quotient
@subfail:
            DEX
            BNE @DIVIDE32_LOOP
            RTS
