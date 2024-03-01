PORTB = $B000   
PORTA = $B001
DDRB = $B002      ; data direction for each data pin
DDRA = $B003

E  = %10000000
RW = %01000000
RS = %00100000

  .org $0
  .word $0000

  .org $C000
reset:
  lda #%11111111  ; all output
  sta DDRB        
  lda #%11111111  ; all output
  sta DDRA        

  lda #%00111000  ; 8-bit mode 2 line display 5x8 font
  sta PORTB       

  lda #0          ; toggle execute
  sta PORTA
  lda #E
  sta PORTA
  lda #0
  sta PORTA

  lda #%00001110  ; display on; cursor on; blink off
  sta PORTB       

  lda #0          ; toggle execute
  sta PORTA
  lda #E
  sta PORTA
  lda #0
  sta PORTA

  lda #%00000110  ; inc and shift cursor; no display shift
  sta PORTB       

  lda #0          ; toggle execute
  sta PORTA
  lda #E
  sta PORTA
  lda #0
  sta PORTA

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

  lda #'l'
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

  lda #'l'
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

  lda #'o'
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

  lda #','
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

  lda #'w'
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

  lda #'o'
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

  lda #'r'
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

  lda #'l'
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

  lda #'d'
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

  lda #'!'
  sta PORTB       

  lda #RS          ; set register select and toggle execute
  sta PORTA
  lda #(RS | E)
  sta PORTA
  lda #0
  sta PORTA

loop:
  jmp loop

  .org $fffc
  .word $C000
  .word $0000
