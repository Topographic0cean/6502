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
.include "../include/defines.s"

PSTARTLO    = $5E00         ; 3,000,000,000
PSTARTHI    = $B2D0

FOURLO      = $2800         ; 4,000,000,000
FOURHI      = $EE6B

LED         = $32           ; Make blinky lights
COUNT       = $3A           ; Only display result every 256 computations

PI          = $42           ; Holds current PI value

N           = $4A           ; Hold the current starting multiplier

ADD         = $7A           ; even if we should add term

MULTC       = HEAP    ; multiplicand
MULTP       = HEAP+4  ; multiplier
RESULT      = HEAP+8  ; result of multiplication

DIVIDEND    = HEAP         
DIVISOR     = HEAP+4       

DECIMAL     = HEAP+12 

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
            sta N+2
            sta N+3
            
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
            jsr store_multc     ; store N in MULTC
            jsr inc_n           ; increase N by 1
            jsr store_multp     ; store N in MULTP
            jsr MULT32          ; RESULT = N * MULT
            jsr store_result    ; store RESULT in MULTC
            jsr inc_n           ; increase N by 1
            jsr store_multp     ; store N in MULTP
            jsr MULT32          ; RESULT = N * MULT
            jsr store_divisor   ; store RESULT in DIVISOR

            ;  Now we calculate 4 / DIVISOR.  
            ; First load DIVIDEND with 4,000,000
            lda #<FOURLO
            sta DIVIDEND
            lda #>FOURLO
            sta DIVIDEND+1
            lda #<FOURHI
            sta DIVIDEND+2
            lda #>FOURHI
            sta DIVIDEND+3 
            jsr DIVIDE32

            ; finally, add to PI if ADD is even,
            ; otherwise subtract
            lda ADD
            and #$01
            beq even

            sec				    ; set carry for borrow
            lda PI
            sbc DIVIDEND			; perform subtraction on the LSBs
            sta PI
            lda PI+1			; do the same for the MSBs, with carry
            sbc DIVIDEND+1			; set according to the previous result
            sta PI+1
            lda PI+2			; do the same for the MSBs, with carry
            sbc DIVIDEND+2			; set according to the previous result
            sta PI+2
            lda PI+3			; do the same for the MSBs, with carry
            sbc DIVIDEND+3			; set according to the previous result
            sta PI+3
even:
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

store_result:
            lda RESULT
            sta MULTC
            lda RESULT+1
            sta MULTC+1
            lda RESULT+2
            sta MULTC+2
            lda RESULT+3
            sta MULTC+3
            rts

store_divisor:
            lda RESULT
            sta DIVISOR
            lda RESULT+1
            sta DIVISOR+1
            lda RESULT+2
            sta DIVISOR+2
            lda RESULT+3
            sta DIVISOR+3
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
            

display_dividend:
            lda DIVIDEND
            sta HEAP
            lda DIVIDEND+1 
            sta HEAP+1
            lda DIVIDEND+2
            sta HEAP+2
            lda DIVIDEND+3 
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
           
