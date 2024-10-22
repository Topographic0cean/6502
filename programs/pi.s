; 
; Computes PI using pi = 3 + 4/(2*3*4) - 4/(4*5*6) ...
;
; We will do only integer arithmetic so multiply everything
; by one billion.
; 
; Also, make sure we have some blinking lights so we
; look more professional.   Assumes that LEDs are attached
; the the lower 7 bits of the 65C22 port A.
;
.setcpu   "65C02"
.debuginfo
.include "defines.s"

DECIMAL   = HEAP+12 

PSTARTLO    = $5E00         ; 3,000,000,000
PSTARTHI    = $B2D0

FOURLO      = $2800         ; 4,000,000,000
FOURHI      = $EE6B

LED         = $32           ; Make blinky lights
COUNT       = $3A           ; Only display result every 256 computations

PI          = $42           ; Holds current PI value

N           = $4A           ; Hold the current starting multiplier
MULT        = $52           ; holds the multiplicant
RESULT      = $5A           ; Result of multiplication. will be used as divisor 
NUMERATOR   = $62           ; Will start with 4,000,000,000 and will hold result of division
REM         = $6A           ; Holds remainder of division
SAVE        = $72           ; holds last subtraction
ADD         = $7A           ; even if we should add term
LOOP        = $82           ; use by mult to count the number of adds

.org START
            lda #$FF
            sta COUNT
            lda #$00
            sta LED
            lda #<PSTARTLO
            sta PI
            lda #>PSTARTLO
            sta PI+1
            lda #<PSTARTHI
            sta PI+2
            lda #>PSTARTHI
            sta PI+3
            
            lda #$02
            sta N
            lda #$00
            sta N+1
            
            jsr DISPLAY_CLEAR

pi_loop:    inc COUNT
            bne @no_led
            lda LED           ; blink some lights
            and #%00011111    ; top 3 bits are for control
            ;jsr DISPLAY_PORT
            inc LED
@no_led:
            ; First thing is to caclulate the denominator of the next
            ; term.  This will start with 2*3*4 then next term is
            ; 4*5*6.   RESULT will hold the multiplication at the end.
            jsr store_n         ; store N in MULT
            jsr inc_n           ; increase N by 1
            jsr mult            ; RESULT = N * MULT
            jsr store_result    ; store RESULT in MULT
            ;jsr inc_n           ; increase N by 1
            ;jsr mult            ; RESULT = N * MULT
            jsr display_result
            jsr delay
            jsr @no_led

            ;  Now we calculate 4 / RESULT.  First load NUMERATOR with
            ; 4,000,000 then divide it by RESULT
            lda #<FOURLO
            sta NUMERATOR
            lda #>FOURLO
            sta NUMERATOR+1
            lda #<FOURHI
            sta NUMERATOR+2
            lda #>FOURHI
            sta NUMERATOR+3 
            jsr divide

            ; finally, add to PI if ADD is even,
            ; otherwise subtract
            lda ADD
            and #$01
            beq even

            sec				    ; set carry for borrow
            lda PI
            sbc NUMERATOR			; perform subtraction on the LSBs
            sta PI
            lda PI+1			; do the same for the MSBs, with carry
            sbc NUMERATOR+1			; set according to the previous result
            sta PI+1
            lda PI+2			; do the same for the MSBs, with carry
            sbc NUMERATOR+2			; set according to the previous result
            sta PI+2
            lda PI+3			; do the same for the MSBs, with carry
            sbc NUMERATOR+3			; set according to the previous result
            sta PI+3
            jmp display_value
even:
            lda PI
            adc NUMERATOR
            sta PI
            lda PI+1
            adc NUMERATOR+1
            sta PI+1
            lda PI+2
            adc NUMERATOR+2
            sta PI+2
            lda PI+3
            adc NUMERATOR+3
            sta PI+3

display_value:
            inc ADD
            jsr display_pi

            lda N
            bne back_to_loop
            inc N+1
            beq stop
back_to_loop:
            jmp pi_loop
stop:
            jmp stop

store_n:
            lda N
            sta MULT
            lda N+1
            sta MULT+1
            lda N+2
            sta MULT+2
            lda N+3
            sta MULT+3
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

store_result:
            lda RESULT
            sta MULT
            lda RESULT+1
            sta MULT+1
            lda RESULT+2
            sta MULT+2
            lda RESULT+3
            sta MULT+3
            rts


mult:       ; MULT - multiplicand
            ; N - multiplier
            ; RESULT - result of multiplication
            lda #$00
            sta RESULT
            sta RESULT+1
            sta RESULT+2
            sta RESULT+3
            ; store N in a temp var so we can decrement it.
            lda N
            sta LOOP
            lda N+1
            sta LOOP+1
            lda N+2
            sta LOOP+2
            lda N+3
            sta LOOP+3
mult_add:
            jsr test_loop      ; check if n is zero
            beq mult_done
            lda MULT
            adc RESULT
            sta RESULT
            lda MULT+1
            adc RESULT+1
            sta RESULT+1
            lda MULT+2
            adc RESULT+2
            sta RESULT+2
            lda MULT+3
            adc RESULT+3
            sta RESULT+3
            jsr dec_loop
            jmp mult_add
mult_done:
            rts

test_loop:
            lda LOOP
            ora LOOP+1
            ora LOOP+2
            ora LOOP+3
            rts

dec_loop:
            lda LOOP
            bne @dec_loop_done
            lda LOOP+1
            bne @dec_loop_done_1
            lda LOOP+2
            bne @dec_loop_done_2
            lda LOOP+3
            beq @dec_loop_all_done
            dec LOOP+3
@dec_loop_done_2:
            dec LOOP+2
@dec_loop_done_1:
            dec LOOP+1
@dec_loop_done:
            dec LOOP
@dec_loop_all_done:
            rts

divide:
            LDA #0              ;Initialize REM to 0
            STA REM
            STA REM+1
            STA REM+2
            STA REM+3
            LDX #32             ;There are 32 bits 
L1:         ASL NUMERATOR       ;Shift hi bit of TERM into REM
            ROL NUMERATOR+1     ;(vacating the lo bit, which will be used for the quotient)
            ROL NUMERATOR+2     ;(vacating the lo bit, which will be used for the quotient)
            ROL NUMERATOR+3     ;(vacating the lo bit, which will be used for the quotient)
            ROL REM
            ROL REM+1
            ROL REM+2
            ROL REM+3
            LDA REM
            SEC                 ;Trial subtraction
            SBC RESULT
            STA SAVE
            LDA REM+1
            SBC RESULT+1
            STA SAVE+1
            LDA REM+2
            SBC RESULT+2
            STA SAVE+2
            LDA REM+3
            SBC RESULT+3
            BCC subfail     ;Did subtraction succeed?
            STA REM+3       ;If yes, save it
            lda SAVE
            sta REM
            lda SAVE+1
            sta REM+1
            lda SAVE+2
            sta REM+3
            INC NUMERATOR    ;and record a 2 in the quotient
subfail:
            DEX
            BNE L1
            rts

display_pi:
            lda PI
            sta HEAP
            lda PI+1 
            sta HEAP+1
            lda PI+2
            sta HEAP+2
            lda PI+3 
            sta HEAP+3
            jsr display_num
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
            

display_numerator:
            lda NUMERATOR
            sta HEAP
            lda NUMERATOR+1 
            sta HEAP+1
            lda NUMERATOR+2
            sta HEAP+2
            lda NUMERATOR+3 
            sta HEAP+3
            jsr display_num
            rts


display_loop:
            lda LOOP
            sta HEAP
            lda LOOP+1 
            sta HEAP+1
            lda LOOP+2
            sta HEAP+2
            lda LOOP+3 
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

delay:
            ldy #$20
@loop_x:    
            ldx #$FF
@loop_a:
            lda #$FF
@delay_loop:
            sbc #$01
            bne @delay_loop
            dex 
            bne @loop_a
            dey 
            bne @loop_x
            rts
           
