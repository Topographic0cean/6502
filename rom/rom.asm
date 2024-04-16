DISPLAY   = $0000 ; 2 byte address of string
HEAP      = $0300
CLOCK     = $0400 ; 2 bytes
LCD       = $7010
UART      = $7020
ROM       = $8000
VECTORS   = $FFFA

E  = %10000000
RW = %01000000
RS = %00100000

  .org ROM
reset:
  ldx #$ff
  txs
  lda #$00
  sta CLOCK
  sta CLOCK+1

  ;jsr interrupt_setup
  cli
  jsr display_setup
  jsr display_clear
  ;jsr clock_loop
  ;jsr keyboard_reset

  lda #">"
  jsr display_putc
  lda #<hello
  sta DISPLAY
  lda #>hello
  sta DISPLAY+1
  jsr display_string
  jsr do_nothing
  jsr keyboard_rx_wait
  jsr display_clear
keyboard_loop:
  jsr keyboard_rx_wait
  jsr display_putc
  ;jsr keyboard_tx_wait
  jsr keyboard_loop
  
clock_loop:
  sei
  lda CLOCK
  sta HEAP
  lda CLOCK + 1
  sta HEAP + 1
  cli
  jsr hextodec
  ldx #$ff
strcpy_loop:
  inx
  lda $304, x
  sta $200, x
  bne strcpy_loop
  jsr display_home
  jsr display_string
  jmp clock_loop

do_nothing:
  jmp do_nothing

  .include "display.asm"
  .include "hextodec.asm"
  .include "interrupts.asm"
  .include "keyboard.asm"

nmi:
irq:
  inc CLOCK
  bne vector_exit
  inc CLOCK + 1
vector_exit:
  bit PORTA
  rti


hello: .asciiz "Hello, world!"

  .org VECTORS
  .word nmi
  .word reset
  .word irq
