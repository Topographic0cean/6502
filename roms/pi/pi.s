.setcpu   "65C02"
.debuginfo
.segment  "ROM"

HEAP      = $0500 ; hex2dec needs 10 bytes
DECIMAL   = HEAP+4 

PSTARTLO = $2800        ; 4,000,000,000
PSTARTHI = $EE6B        

PI      = $0050 ; 4 bytes
N       = $0054
TERM    = $0058
TDIV    = $006C
REM     = $0070
SUBSAVE = $0074

RESET:      jsr DISPLAY_SETUP
            lda #$00
            sta N
            sta N+1
            lda #<PSTARTLO
            sta PI
            lda #>PSTARTLO
            sta PI+1
            lda #<PSTARTHI
            sta PI+2
            lda #>PSTARTHI
            sta PI+3

pi_loop:    ; Display current PI estimate
            lda PI+2
            sta HEAP
            lda PI+3 
            sta HEAP+1
            jsr display_num

            ; increment N
            inc N
            bne @n_done
            inc N + 1
            bne @n_done
            inc N + 2
            bne @n_done
            inc N + 3

@n_done:    ; TDIV is 2*N+1
      lda N
      clc
      adc N
      adc #$01
      sta TDIV
      lda N+1
      adc N+1
      sta TDIV+1
      lda N+2
      adc N+2
      sta TDIV+2
      lda N+3
      adc N+3
      sta TDIV+3

      ; term is PSTART / TDIV
      lda #<PSTARTLO
      sta TERM
      lda #>PSTARTLO
      sta TERM+1
      lda #<PSTARTHI
      sta TERM+2
      lda #>PSTARTHI
      sta TERM+3
      LDA #0      ;Initialize REM to 0
      STA REM
      STA REM+1
      STA REM+2
      STA REM+3
      LDX #32     ;There are 32 bits 
L1:   ASL TERM    ;Shift hi bit of TERM into REM
      ROL TERM+1  ;(vacating the lo bit, which will be used for the quotient)
      ROL TERM+2  ;(vacating the lo bit, which will be used for the quotient)
      ROL TERM+3  ;(vacating the lo bit, which will be used for the quotient)
      ROL REM
      ROL REM+1
      ROL REM+2
      ROL REM+3
      LDA REM
      SEC         ;Trial subtraction
      SBC TDIV
      STA SUBSAVE
      LDA REM+1
      SBC TDIV+1
      STA SUBSAVE+1
      LDA REM+2
      SBC TDIV+2
      STA SUBSAVE+2
      LDA REM+3
      SBC TDIV+3
      BCC SUBFAIL   ;Did subtraction succeed?
      STA REM+3     ;If yes, save it
      lda SUBSAVE
      sta REM
      lda SUBSAVE+1
      sta REM+1
      lda SUBSAVE+2
      sta REM+2
      INC TERM    ;and record a 1 in the quotient
SUBFAIL:
      DEX
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
      lda PI+2			; do the same for the MSBs, with carry
      sbc TERM+2			; set according to the previous result
      sta PI+2
      lda PI+3			; do the same for the MSBs, with carry
      sbc TERM+3			; set according to the previous result
      sta PI+3
      jmp pi_loop

@even:
      clc
      lda PI
      adc TERM
      sta PI
      lda PI+1
      adc TERM+1
      sta PI+1
      lda PI+2
      adc TERM+2
      sta PI+2
      lda PI+3
      adc TERM+3
      sta PI+3
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
IRQ:  rti

.include "../lib/display.s"
.include "../lib/hextodec.s"
.include "../lib/vectors.s"