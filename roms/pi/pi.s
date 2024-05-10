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
REM    = $0048


RESET:
  jsr DISPLAY_SETUP
  lda #$00
  sta N
  sta N+1
  lda #<PSTART
  sta PI
  lda #>PSTART
  sta PI+1
pi_loop:
  ; Display current PI estimate
  lda PI
  sta H2DRAM
  lda PI+1 
  sta H2DRAM+1
  jsr display_num

  ; increment N
  inc N
  bne @inc_n_done
  inc N + 1
@inc_n_done:

  ; TDIV is 2*N+1
  lda N
  clc
  adc N
  adc #$01
  sta TDIV
  lda N+1
  adc N+1
  sta TDIV+1

  ; term is PSTART / TDIV
  lda #<PSTART
  sta TERM
  lda #>PSTART
  sta TERM+1
        LDA #0      ;Initialize REM to 0
        STA REM
        STA REM+1
        LDX #16     ;There are 16 bits 
L1:     ASL TERM    ;Shift hi bit of TERM into REM
        ROL TERM+1  ;(vacating the lo bit, which will be used for the quotient)
        ROL REM
        ROL REM+1
        LDA REM
        SEC         ;Trial subtraction
        SBC TDIV
        TAY
        LDA REM+1
        SBC TDIV+1
        BCC L2      ;Did subtraction succeed?
        STA REM+1   ;If yes, save it
        STY REM
        INC TERM    ;and record a 1 in the quotient
L2:     DEX
        BNE L1

    ; if N is even then add PI + TERM otherwise subtract
    lda N 
    and #$01
    beq @even
    ; odd
    sec				; set carry for borrow purpose
	  lda PI
	  sbc TERM			; perform subtraction on the LSBs
	  sta PI
	  lda PI+1			; do the same for the MSBs, with carry
	  sbc TERM+1			; set according to the previous result
	  sta PI+1
    jmp pi_loop

@even:
    clc
    lda PI
    adc TERM
    sta PI
    lda PI+1
    adc TERM+1
    sta PI+1
  jmp pi_loop

display_num:
  jsr DISPLAY_CLEAR
  jsr HEXTODEC
  ldy #$00
@output:
  lda DECIMAL, y
  beq @done
  jsr DISPLAY_PUTC
  iny
  jmp @output
@done:
  rts




NMI:
IRQ:
  rti

.include "../lib/display.s"
.include "../lib/hextodec.s"
.include "../lib/vectors.s"
