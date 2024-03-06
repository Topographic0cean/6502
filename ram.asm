MMIO  = $7000
ROM_START = $8000

PORTB = MMIO
PORTA = (MMIO+1)
DDRB = (MMIO+2)
DDRA = (MMIO+3)

E  = %10000000
RW = %01000000
RS = %00100000

  .org $0
  .word $0000

  .org ROM_START

setup_stack:
  ldx #$ff
  txs

setup_lcd:
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

display_text:
  lda #%00000001; clear display
  jsr toggle_execute
  ldx #$00
loop:
  lda string,x
  beq done
  jsr putc
  inx
  jmp loop 
done:
  jsr display_text

putc:
  jsr wait_lcd
  sta PORTB       
  pha
  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA
  pla
  rts

wait_lcd:
  pha
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
  pla
  rts

toggle_execute:
  jsr wait_lcd
  sta PORTB       
  pha
  lda #0
  sta PORTA
  lda #E
  sta PORTA
  lda #0
  sta PORTA
  pla
  rts

string:
  .asciiz "Hello, world!"
  
  .org $fffc
  .word ROM_START
  .word $0000
