;  VIA chip controls the LCD display as well as the serial CTS and various LED blinkenlights
;
;  PORT B is attached the LCD
;       bit  7   6   5   4   3   2   1   0
;           ES  RS  RW  -   DB7 DB6 DB5 DB4 
;        
;  PORT A is set as follows
;       bit 0       CTS
;       bits 1-7    LED blinkenlights
;

.segment    "ROM"

PORT    = $02       ; keep track of what PORTA should be.  Since it is used by different
                    ; functions.  We do not expect them to know what each is doing.

LCD     = $6000
PORTB   = LCD
PORTA   = (LCD+1)
DDRB    = (LCD+2)
DDRA    = (LCD+3)

E  = %10000000
RW = %01000000
RS = %00100000

VIA_SETUP: 
                lda #%11111111  ; all output
                sta DDRB        
                lda #%11111111  ; all output
                sta DDRA        

                ; initialize port a to 1 (CTS set)
                lda #$01
                sta PORT
                sta PORTA
                lda #%00110000  ; 4-bit mode 
                jsr toggle_execute
                lda #%00001110  ; display on; cursor on; blink off
                jsr toggle_execute
                lda #%00000110  ; inc and shift cursor; no display shift
                jsr toggle_execute
                rts


DISPLAY_CLEAR:  lda #%00000001
                jsr toggle_execute
                rts

DISPLAY_HOME:   lda #%00000010
                jsr toggle_execute
                rts

DISPLAY_PUTC:   ; put the character in the accumulator to LCD
                pha 
                jsr wait_lcd
                pla
                ora #RS          ; set register select and toggle execute
                and #(~E)
                sta PORTB
                ora #(RS | E)
                sta PORTB
                and #(!(RS|E))
                sta PORTB
                rts

                ; Set CTS to the value of bit 0 in the accumulator
VIA_CTS:        pha
                bit #$01
                bne @turn_on_cts
                lda PORT
                and #%11111110
                jmp @cts_done
@turn_on_cts:   lda PORT
                ora #%00000001
@cts_done:
                sta PORT
                sta PORTA
                pla
                rts

wait_lcd:       lda #%0000000  ; all input
                sta DDRB   
display_busy:   lda #RW
                sta PORTB
                lda #(RW | E)
                sta PORTB
                lda PORTB
                and #%10000000
                bne display_busy
                lda #RW
                sta PORTB
                lda #%11111111  ; all output
                sta DDRB        
                rts

toggle_execute: pha
                jsr wait_lcd
                pla
                sta PORTB       
                and #(~E)
                sta PORTB
                ora #E
                sta PORTB
                and #(~E)
                sta PORTB
                rts
