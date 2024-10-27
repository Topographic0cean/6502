.setcpu   "65C02"
.debuginfo
.include "../include/defines.s"

DIVIDEND    = HEAP         ; 32 bit numerator
DIVISOR     = HEAP+4       ; 16 bit divisor
REM         = HEAP+8       ; 32 bit remainder 

DECIMAL     = HEAP+12 

SAVE_REM    = $10
SAVE_QUOTE  = $14

.org START
            jsr DISPLAY_CLEAR
            
            lda #$00
            sta DIVIDEND+0
            sta DIVIDEND+1
            sta DIVIDEND+2
            sta DIVIDEND+3
            sta DIVISOR+0
            sta DIVISOR+1
            sta DIVISOR+2
            sta DIVISOR+3

;           4093493 / 2345 = 1745 R 1468
            ;jmp @other
            lda #$35
            sta DIVIDEND
            lda #$76
            sta DIVIDEND+1
            lda #$3E
            sta DIVIDEND+2
            LDA #$29
            sta DIVISOR
            lda #$09
            sta DIVISOR+1
            jmp @dodivide
@other:
            lda #$10
            sta DIVIDEND
            LDA #$02
            sta DIVISOR
@dodivide:
            
            jsr DIVIDE32
            
            jsr save_results

            jsr display_quotient
            jsr ONE_SEC_DELAY
            jsr ONE_SEC_DELAY
            jsr ONE_SEC_DELAY
            jsr ONE_SEC_DELAY
            jsr ONE_SEC_DELAY
            jsr display_remainder
@stop:
            jmp @stop


save_results:
            lda DIVIDEND
            sta SAVE_QUOTE
            lda DIVIDEND+1
            sta SAVE_QUOTE+1
            lda DIVIDEND+2
            sta SAVE_QUOTE+2
            lda DIVIDEND+3
            sta SAVE_QUOTE+3
            lda REM
            sta SAVE_REM
            lda REM+1
            sta SAVE_REM+1
            lda REM+2
            sta SAVE_REM+2
            lda REM+3
            sta SAVE_REM+3
            rts

display_quotient:
            lda SAVE_QUOTE
            sta HEAP
            lda SAVE_QUOTE+1 
            sta HEAP+1
            lda SAVE_QUOTE+2
            sta HEAP+2
            lda SAVE_QUOTE+3 
            sta HEAP+3
            jsr display_num
            rts
display_remainder:
            lda SAVE_REM
            sta HEAP
            lda SAVE_REM+1 
            sta HEAP+1
            lda SAVE_REM+2
            sta HEAP+2
            lda SAVE_REM+3 
            sta HEAP+3
            jsr display_num
            rts
display_divisor:
            lda DIVISOR
            sta HEAP
            lda DIVISOR+1 
            sta HEAP+1
            lda DIVISOR+2
            sta HEAP+2
            lda DIVISOR+3 
            sta HEAP+3
            jsr display_num
            rts
display_num:
            jsr DISPLAY_HOME
            jsr HEXTODEC
            ldy #$00
@output:
            lda DECIMAL, y
            beq @done
            jsr DISPLAY_PUTC
            iny
            jmp @output
@done:
            rts
