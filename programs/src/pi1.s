; 
; Computes PI using pi/4 = arctan(1) as Taylor series.
;    pi = 4 - 4/3 + 4/5 - 4/7 + ...
; This is not the most efficient computation, but it 
; seems to slowly get there.
; 
; Also, make sure we have some blinking lights so we
; look more professional.   Assumes that LEDs are attached
; the the upper 5 bits of the 65C22 port A.
;
.setcpu   "65C02"
.debuginfo
.include "../include/defines.s"

DECIMAL   = HEAP+12 

PSTARTLO = $2800        ; 4,000,000,000
PSTARTHI = $EE6B        

COUNT       = $41 ; Only display result every 256 computations
PI          = $50 ; Each of thse vars are 4 bytes

N           = $58 ; starts at 2 and increments by 2

DIVIDEND    = HEAP         
DIVISOR     = HEAP+4  

.org START
            lda #$FF
            sta COUNT
            lda #$01
            sta N
            lda #$00
            sta N+1
            sta N+2
            sta N+3
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
            lda COUNT
            and #$7F
            bne @no_display
            lda PI            ; blink some lights
            jsr DISPLAY_LEDS
            jsr display_pi
            
@no_display:
            ;jsr display_n
            jsr inc_n
            jsr inc_n

            jsr load_dividend
            jsr load_divisor
            jsr DIVIDE32

            ;jsr display_num

            lda COUNT
            and #$01
            bne @add

@subtract: 
            sec
            lda PI
            sbc DIVIDEND
            sta PI
            lda PI+1
            sbc DIVIDEND+1
            sta PI+1
            lda PI+2
            sbc DIVIDEND+2
            sta PI+2
            lda PI+3
            sbc DIVIDEND+3
            sta PI+3
            jmp @done
@add:
            clc
            lda PI
            adc DIVIDEND
            sta PI
            lda PI+1
            adc DIVIDEND+1
            sta PI+1
            lda PI+2
            adc DIVIDEND+2
            sta PI+2
            lda PI+3
            adc DIVIDEND+3
            sta PI+3

@done:
            lda DIVIDEND
            ora DIVIDEND+1
            ora DIVIDEND+2
            ora DIVIDEND+3
            beq @stop
            jmp pi_loop
@stop:
            jmp @stop

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



load_divisor:
            lda N
            sta DIVISOR
            lda N+1
            sta DIVISOR+1
            lda N+2
            sta DIVISOR+2
            lda N+3
            sta DIVISOR+3
            rts

load_dividend:
            lda #<PSTARTLO
            sta DIVIDEND
            lda #>PSTARTLO
            sta DIVIDEND+1
            lda #<PSTARTHI
            sta DIVIDEND+2
            lda #>PSTARTHI
            sta DIVIDEND+3
            rts

inc_n:
            inc N
            bne @n_done
            inc N + 1
            bne @n_done
            inc N + 2
            bne @n_done
            inc N + 3
@n_done:
            rts