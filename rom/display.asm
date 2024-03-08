
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

display_string:
    ; displays the string stored at display_string_buffer
  lda #%00000001; clear display
  jsr toggle_execute
  ldx #$00
loop:
  lda DISPLAY, x
  beq done
  jsr display_putc
  inx
  jmp loop 
done:
  rts

display_putc:
  pha
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
busy:     
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne busy
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

