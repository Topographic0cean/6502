.setcpu   "65C02"
.debuginfo
.segment  "ROM"

H2DRAM    = $0500 ; hex2dec needs 10 bytes
DECIMAL   = H2DRAM+4 

PSTART = $9C40        ; 40000

PI     = $0050 ; 2 bytes
N      = $0042
TERM   = $0044
TDIV   = $0046


RESET:
  jsr DISPLAY_SETUP
  lda #$00
  sta N
  sta N+1
  lda #<PSTART
  sta PI
  lda #>PSTART
  sta PI+1

@loop:
  ; Display current PI estimate
  jsr DISPLAY_HOME
  lda PI
  sta H2DRAM
  lda PI+1 
  sta H2DRAM+1
  jsr HEXTODEC
  ldy #$00
output:
  lda DECIMAL, y
  beq @done
  jsr DISPLAY_PUTC
  iny
  jmp output
@done:
  ; increment N
  inc N
  bne @n_small
  inc N + 1
@n_small:
  lda N
  



NMI:
IRQ:
  rti

.include "../lib/display.s"
.include "../lib/hextodec.s"
.include "../lib/vectors.s"
