.setcpu   "65C02"
.debuginfo
.segment  "ROM"

DISPLAY   = $0000
HEAP      = $0300
CLOCK     = $0400 ; 2 bytes

PCR = $600C
IER = $600E

RESET:
  lda #$ff
  txs
  jsr DISPLAY_SETUP
  lda #$00
  sta CLOCK
  sta CLOCK+1

  lda #$82    ; set CA1
  sta IER
  lda #$00    ; set CA1 to negative active edge
  sta PCR

clock_loop:
  sei
  lda CLOCK
  sta HEAP
  lda CLOCK + 1
  sta HEAP + 1
  cli
  jsr HEXTODEC
  lda #$04
  sta DISPLAY
  lda #$03
  sta DISPLAY+1
  jsr DISPLAY_HOME
  jsr DISPLAY_STRING
  jmp clock_loop

do_nothing:
  jmp do_nothing

NMI:
IRQ:
  inc CLOCK
  bne vector_exit
  inc CLOCK + 1
vector_exit:
  bit PORTA
  rti

.include "../lib/display.s"
.include "../lib/hextodec.s"
.include "../lib/vectors.s"

