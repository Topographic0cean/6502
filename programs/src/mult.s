
.setcpu   "65C02"
.debuginfo
.include "../../rom/include/defines.s"

N           = $32           ; Hold the current starting multiplier

DECIMAL   = HEAP+12 
MULTC     = HEAP    ; multiplicand
MULTP     = HEAP+4  ; multiplier
RESULT    = HEAP+8  ; result of multiplication

.org START
            jsr DISPLAY_CLEAR
            lda #$02
            sta N 
            lda #$00
            sta N+1
            sta N+2
            sta N+3
loop:
            jsr store_multp
            jsr inc_n
            jsr store_multc
            jsr MULT32
            jsr display_result
            jsr ONE_SEC_DELAY
            jsr ONE_SEC_DELAY
            jsr ONE_SEC_DELAY
            jsr ONE_SEC_DELAY
            jsr ONE_SEC_DELAY
done:   
            jmp loop


store_multp:
            lda N 
            sta MULTP
            lda N+1
            sta MULTP+1
            lda N+2
            sta MULTP+2
            lda N+3
            sta MULTP+3
            rts
store_multc:
            lda N 
            sta MULTC
            lda N+1
            sta MULTC+1
            lda N+2
            sta MULTC+2
            lda N+3
            sta MULTC+3
            rts
inc_n:     
            inc N
            bne @inc_n_done
            inc N+1
            bne @inc_n_done
            inc N+2
            bne @inc_n_done
            inc N+3
@inc_n_done:
            rts

display_n:
            lda N
            sta HEAP
            lda N+1 
            sta HEAP+1
            lda N+2
            sta HEAP+2
            lda N+3 
            sta HEAP+3
            jsr display_num
            rts
display_result:
            lda RESULT
            sta HEAP
            lda RESULT+1 
            sta HEAP+1
            lda RESULT+2
            sta HEAP+2
            lda RESULT+3 
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
