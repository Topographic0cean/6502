
.setcpu   "65C02"
.debuginfo
.include "defines.s"

N           = $32           ; Hold the current starting multiplier

DECIMAL     = HEAP+12 
MULTP       = $4A           ; Hold the current starting multiplier
MULTC       = $52           ; holds the multiplicant
RESULT      = $5A           ; Result of multiplication. will be used as divisor 

.org START
            jsr DISPLAY_CLEAR
            lda #$02
            sta N 
            lda #$00
            sta N+1
            sta N+2
            sta N+3
            jsr display_n
            jsr store_multp
            jsr inc_n
            jsr store_multc
            jsr mult
            jsr display_result
done:   
            jmp done

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

mult:       ; MULTC     - multiplicand
            ; MULTP     - multiplier
            ; RESULT    - result of multiplication
            lda #$00
            sta RESULT
            sta RESULT+1
            sta RESULT+2
            sta RESULT+3
mult_add:
            jsr test_multp       ; check if MULTP is zero
            beq mult_done
            lda MULTC
            adc RESULT
            sta RESULT
            lda MULTC+1
            adc RESULT+1
            sta RESULT+1
            lda MULTC+2
            adc RESULT+2
            sta RESULT+2
            lda MULTC+3
            adc RESULT+3
            sta RESULT+3
            jsr dec_multp
            jmp mult_add
mult_done:
            rts

test_multp:
            lda MULTP
            ora MULTP+1
            ora MULTP+2
            ora MULTP+3
            rts

dec_multp:
            lda MULTP
            bne @dec_done
            lda MULTP+1
            bne @dec_done_1
            lda MULTP+2
            bne @dec_done_2
            lda MULTP+3
            beq @dec_all_done
            dec MULTP+3
@dec_done_2:
            dec MULTP+2
@dec_done_1:
            dec MULTP+1
@dec_done:
            dec MULTP
@dec_all_done:
            rts