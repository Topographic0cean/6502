
.segment    "ROM"

LCD     = $6000
PORTB   = LCD
PORTA   = (LCD+1)
DDRB    = (LCD+2)
DDRA    = (LCD+3)

E  = %10000000
RW = %01000000
RS = %00100000

DISPLAY_SETUP:      
    ; setup the display to 8 bits 2 lines
  lda #%11111111  ; all output
  sta DDRB        
  lda #%11111111  ; all output
  sta DDRA        
  lda #%00111000  ; 8-bit mode 2 line display 5x8 font
  jsr toggle_execute
  lda #%00001110  ; display on; cursor on; blink off
  jsr toggle_execute
  lda #%00000110  ; inc and shift cursor; no display shift
  jsr toggle_execute
  rts

DISPLAY_CLEAR:
  lda #%00000001
  jsr toggle_execute
  rts

DISPLAY_HOME:
  lda #%00000010
  jsr toggle_execute
  rts

DISPLAY_PUTC:     ; put the character in the accumulator to
  pha             ; the LCD
  jsr wait_lcd
  pla
  sta PORTB       
  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA
  rts

wait_lcd:
  lda #%0000000  ; all output
  sta DDRB   
display_busy:     
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne display_busy
  lda #RW
  sta PORTA
  lda #%11111111  ; all output
  sta DDRB        
  rts

toggle_execute:
  pha
  jsr wait_lcd
  pla
  sta PORTB       
  lda #0
  sta PORTA
  lda #E
  sta PORTA
  lda #0
  sta PORTA
  rts
