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

PSTARTLO    = $5E00        ; 3,000,000,000
PSTARTHI    = $B2D0

FOURLO      = $2800
FOURHI      = $EE6B

LED         = $40 ; Make blinky lights
COUNT       = $41 ; Only display result every 256 computations

PI          = $52 ; Holds current PI value

N           = $5A ; Hold the current starting multiplier
MULT        = $62
RESULT      = $6A

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

            jsr display_result

stop:
            ;jmp pi_loop
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
            sta TERM
            sta TERM+1
            sta TERM+2
            sta TERM+3
            LDA #0      ;Initialize REM to 0
            STA REM
            STA REM+1
            STA REM+2
            STA REM+3
            LDX #32     ;There are 32 bits 
L1:         ASL TERM    ;Shift hi bit of TERM into REM
            ROL TERM+1  ;(vacating the lo bit, which will be used for the quotient)
            ROL TERM+2  ;(vacating the lo bit, which will be used for the quotient)
            ROL TERM+3  ;(vacating the lo bit, which will be used for the quotient)
            ROL REM
            ROL REM+1
            ROL REM+2
            ROL REM+3
            LDA REM
            SEC         ;Trial subtraction
            SBC TDIV
            STA SUBSAVE
            LDA REM+1
            SBC TDIV+1
            STA SUBSAVE+1
            LDA REM+2
            SBC TDIV+2
            STA SUBSAVE+2
            LDA REM+3
            SBC TDIV+3
            BCC SUBFAIL   ;Did subtraction succeed?
            STA REM+3     ;If yes, save it
            lda SUBSAVE
            sta REM
            lda SUBSAVE+1
            sta REM+1
            lda SUBSAVE+2
            sta REM+2
            INC TERM    ;and record a 1 in the quotient
SUBFAIL:
            DEX
            BNE L1

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
