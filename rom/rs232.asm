UART_DATA    = UART
UART_STATUS  = (UART+1)
UART_CMD     = (UART+2)
UART_CTRL    = (UART+3)

rs232_setup:
  lda #$00
  sta UART_STATUS   ; reset the chip
  lda #$1F         ; N-8-1 19200 BAUD
  sta UART_CTRL
  lda #$0b          ; no parity. no echo. no interrupts
  sta UART_CMD
  rts 

rs232_recv:
  jsr rs232_delay
  lda UART_STATUS
  and #$08          ; check rx buffer status flag
  beq rs232_recv
  lda UART_DATA
  rts

rs232_send:
  sta UART_DATA
rs232_send_loop:
  pha
  lda UART_STATUS
  and #$10        ; check transmit buffer status
  beq rs232_send_loop
  jsr rs232_delay
  pla
  rts

rs232_delay:
  phx
  ldx #100
rs232_delay_loop:
  dex
  bne rs232_delay_loop
  plx
  rts