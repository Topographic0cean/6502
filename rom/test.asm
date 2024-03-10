DISPLAY   = $0200
HEAP      = $0300
MMIO      = $7000
ROM       = $8000
VECTORS   = $FFFA


PORTB = MMIO
PORTA = (MMIO+1)
DDRB = (MMIO+2)
DDRA = (MMIO+3)

E  = %10000000
RW = %01000000
RS = %00100000

  .org $0
  .word $0000

  .org DISPLAY
  .word 0000

  .org HEAP
  .word 0000

  .word 0000

  .org ROM
reset:
  ldx #$ff
  txs
  cli
  jsr display_setup
  jsr wait_lcd
  lda #'H'
  sta PORTB       
  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA
  lda #'e'
  sta PORTB       
  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA
loop:
  jmp loop

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

nmi:
irq:
vector_exit:
  rti

  .org VECTORS
  .word nmi
  .word reset
  .word irq