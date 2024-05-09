.setcpu   "65C02"
.debuginfo
.segment  "ROM"

HEAP      = $0000 ; hex2dec needs 10 bytes
DECIMAL   = $0004
CLOCK     = $0010 ; 2 bytes

PCR = $600C
IER = $600E

RESET:
  jsr DISPLAY_SETUP
  lda #$00
  sta CLOCK
  sta CLOCK+1

  lda #$82    ; set CA1
  sta IER
  lda #$00    ; set CA1 to negative active edge
  sta PCR

clock_loop:
  jsr DISPLAY_HOME
  sei
  lda CLOCK
  sta HEAP
  lda CLOCK + 1
  sta HEAP + 1
  cli
  jsr HEXTODEC
  ldy #$00
output:
  lda (DECIMAL), y
  beq done
  jsr DISPLAY_PUTC
  iny
  jmp output
done:
  jmp clock_loop

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

