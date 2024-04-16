PORTB = LCD
PORTA = (LCD+1)
DDRB  = (LCD+2)
DDRA  = (LCD+3)

display_setup:      
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

display_clear:
  lda #%00000001
  jsr toggle_execute
  rts

display_home:
  lda #%00000010
  jsr toggle_execute
  rts

display_string:
    ; displays the string whose address is stored at DISPLAY
  ldy #$00
display_loop:
  lda (DISPLAY),y
  beq display_done
  jsr display_putc
  iny
  jmp display_loop
display_done:
  rts

display_putc:     ; put the character in the accumulator to
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
