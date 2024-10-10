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
MULT        = $52
RESULT      = $5A           ; Result of multiplication. will be used as divisor 
NUMERATOR   = $62           ; Will start with 4,000,000,000 and will hold result of division
REM         = $6A           ; Holds remainder of division
SAVE        = $72           ; holds last subtraction
ADD         = $7A           ; even if we should add term

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
            lda N
            sta MULT
            lda #$00
            sta MULT+1
            sta MULT+2
            sta MULT+3

            inc N
            lda N 
            jsr mult

            lda RESULT
            sta MULT
            lda RESULT+1
            sta MULT+1
            lda RESULT+2
            sta MULT+2
            lda RESULT+3
            sta MULT+3
            inc N
            lda N
            jsr mult

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
            beq stop
            jmp pi_loop
stop:
            jmp stop

mult:       ; MULT - multiplicand
            ; A - multiplier
            ; RESULT - result of multiplication
            tay
            lda #$00
            sta RESULT
            sta RESULT+1
            sta RESULT+2
            sta RESULT+3
            tya 
            tax
mult_add:
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
            dex
            jmp mult_add
mult_done:
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
            sta REM+2
            INC NUMERATOR    ;and record a 1 in the quotient
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
