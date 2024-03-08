DISPLAY   = $0200
HEAP      = $0300
MMIO      = $7000
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

  .org $200
  .asciiz "Hello, world!"

  .org $300
  .word 1729

  .org ROM_START

setup_stack:
  ldx #$ff
  txs

  jsr display_setup
  jsr display_string

  jsr hextodec
  ldx #$ff
strcpy_loop:
  inx
  lda $304, x
  sta $200, x
  bne strcpy_loop
  jsr display_string

infinite_loop:
  jmp infinite_loop

  .include "display.asm
  .include "hextodec.asm
  
  .org $fffc
  .word ROM_START
  .word $0000
