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

FOURBLO     = $2800
FOURBHI     = $EE6B

LED         = $40 ; Make blinky lights
COUNT       = $41 ; Only display result every 256 computations
PI          = $50 ; Holds current PI value

ADDSUB      = $58 ; zero if we add, otherwise subtract
TERM        = $60 ; will hold term we add or subtract to PI
DIVISOR     = $70
REM         = $78
MULT        = $82

.org START
            lda #$FF
            sta COUNT
            lda #$00
            sta LED
            sta ADDSUB
            lda #<PSTARTLO
            sta PI
            lda #>PSTARTLO
            sta PI+1
            lda #<PSTARTHI
            sta PI+2
            lda #>PSTARTHI
            sta PI+3
            jsr DISPLAY_CLEAR

pi_loop:    inc COUNT
            bne @no_led
            lda LED           ; blink some lights
            and #%00011111    ; top 3 bits are for control
            ;jsr DISPLAY_PORT
            inc LED
@no_led:
            ;lda PI
            ;sta HEAP
            ;lda PI+1 
            ;sta HEAP+1
            ;lda PI+2
            ;sta HEAP+2
            ;lda PI+3 
            ;sta HEAP+3
            ;jsr display_num

            lda #$04
            ldx #$03
            jsr mult
            sta HEAP
            lda #$00
            sta HEAP+1
            sta HEAP+2
            sta HEAP+3
            jsr display_num

stop:
            ;jmp pi_loop
            jmp stop

mult:       ; A - multiplicand
            ; X - multiplier
            sta MULT
mult_add:
            dex
            beq mult_done
            adc MULT
            jmp mult_add
mult_done:
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
