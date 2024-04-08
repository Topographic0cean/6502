DISPLAY   = $0200
HEAP      = $0300
CLOCK     = $0400 ; 2 bytes
MMIO      = $7010
ROM       = $8000
VECTORS   = $FFFA

PORTB = MMIO      ; data
PORTA = (MMIO+1)  ; control
DDRB = (MMIO+2)
DDRA = (MMIO+3)

E  = %10000000
RW = %01000000
RS = %00100000

D8B2L5B8  = %00111000   ; Set Diplay to 8-bit mode, 2 lines and 5x8
DONCURSOR = %00001110   ; Display on, cursor on, blink off
DMODE     = %00000110   ; left to right, no display shift

  .org ROM

reset:
  ldx #$ff
  txs
  cli
  jsr display_setup
  jsr display_clear

  ldx #0
print:
  lda msg,x
  beq loop
  jsr display_putc
  inx
  jmp print

loop:
  jmp loop

  .include "../rom/display.asm

nmi:
irq:
vector_exit:
  rti

msg: .asciiz "Hello, world!"

  .org VECTORS
  .word nmi
  .word reset
  .word irq
