;  VIA chip controls the LCD display as well as the serial CTS and various LED blinkenlights
;
;  PORT B is attached the LCD
;       bit  7   6   5   4   3   2   1   0
;           E   Rw  RS  -   DB7 DB6 DB5 DB4 
;        
;  PORT A is set as follows
;       bit 0       CTS
;       bits 1-7    LED blinkenlights
;

.segment    "ROM"

PORTB   = LCD
PORTA   = (LCD+1)
DDRB    = (LCD+2)
DDRA    = (LCD+3)

E  = %10000000
RW = %01000000
RS = %00100000

ready: .byte "READY", $00

VIA_SETUP: 
                lda #%11111111  ; all output
                sta DDRB        
                lda #%11111111  ; all output
                sta DDRA        

                ; initialize port a to 1 (CTS set)
                lda #$01
                sta PORT
                sta PORTA

                jsr DISPLAY_INIT

                jsr DISPLAY_CLEAR

                ldy #00
@start_message: lda ready, y
                beq @end_message
                jsr DISPLAY_PUTC
                iny
                jmp @start_message
@end_message:
                rts


DISPLAY_INIT:
                lda #%00000011 ; Set 8-bit mode
                sta PORTB
                ora #E
                sta PORTB
                and #%00001111
                sta PORTB

                lda #%00000011 ; Set 8-bit mode
                sta PORTB
                ora #E
                sta PORTB
                and #%00001111
                sta PORTB

                lda #%00000011 ; Set 8-bit mode
                sta PORTB
                ora #E
                sta PORTB
                and #%00001111
                sta PORTB
skip:
                ; Okay, now we're really in 8-bit mode.
                ; Command to get to 4-bit mode ought to work now
                lda #%00000010 ; Set 4-bit mode
                sta PORTB
                ora #E
                sta PORTB
                and #%00001111
                sta PORTB
                lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
                jsr lcd_send
                lda #%00001110  ; display on; cursor on; blink off
                jsr lcd_send
                lda #%00000110  ; inc and shift cursor; no display shift
                jsr lcd_send
                rts

DISPLAY_CLEAR:  
                lda #%00000001
                jsr lcd_send
                rts

DISPLAY_HOME:   
                lda #%00000010
                jsr lcd_send
                rts

DISPLAY_PUTC:   ; put the character in the accumulator to LCD
                jsr lcd_wait
                pha
                lsr
                lsr
                lsr
                lsr
                ora #RS
                sta PORTB
                ora #E
                sta PORTB
                eor #E
                sta PORTB
                pla
                and #%00001111
                ora #RS
                sta PORTB
                ora #E
                sta PORTB
                eor #E
                sta PORTB
                rts

DISCHAR:        jsr GETBYT
                txa
                jsr DISPLAY_PUTC
                rts

DISPRINT:
                rts

                ; Set CTS to the value of bit 0 in the accumulator
VIA_CTS:       
                bit #$01
                bne @turn_on_cts
                lda PORT
                and #%11111110
                jmp cts_done
@turn_on_cts:   lda PORT
                ora #%00000001
                jmp cts_done

DISPLAY_LEDS:   tay  
                lda PORT
                and #%00000001           ; clear all but CTS
                sta PORT
                tya 
                and #%11111000           ; only the top 5 bits count
                ora PORT
cts_done:
                sta PORT
                sta PORTA
                rts

lcd_wait:       pha 
                lda #%11110000 ; data input
                sta DDRB   
lcd_busy:       lda #RW
                sta PORTB
                lda #(RW | E)
                sta PORTB
                lda PORTB
                pha
                lda #RW
                sta PORTB
                lda #(RW | E)
                sta PORTB
                lda PORTB
                pla
                and #%00001000
                bne lcd_busy
                lda #RW
                sta PORTB
                lda #%11111111  ; all output
                sta DDRB   
                pla
                rts

lcd_send:   
                jsr lcd_wait
                pha
                lsr
                lsr
                lsr
                lsr
                jsr toggle_execute
                pla
                and #%00001111
                jsr toggle_execute
                rts

toggle_execute: 
                sta PORTB       
                ora #E
                sta PORTB
                eor #E
                sta PORTB
                rts
