DISPLAY   = $0200
HEAP      = $0300
CLOCK     = $0400 ; 2 bytes
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

  .org CLOCK
  .word 0000

  .org ROM
reset:
  ldx #$ff
  txs
  cli
  jsr display_setup

infinite_loop:
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
  jmp infinite_loop

  .include "display.asm
  .include "hextodec.asm

nmi:
irq:
  inc CLOCK
  bne vector_exit
  inc CLOCK + 1
vector_exit:
  rti

  .org VECTORS
  .word nmi
  .word reset
  .word irq
