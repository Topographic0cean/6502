UART_DATA    = UART
UART_STATUS  = (UART+1)
UART_CMD     = (UART+2)
UART_CTRL    = (UART+3)


keyboard_reset:
  lda #$00
  sta UART_STATUS
  lda #$1F          ; N-8-1 19200 BAUD
  sta UART_CTRL
  lda #$0B          ; no parity. no echo. no interrupts
  sta UART_CMD
  rts 


keyboard_rx_wait:
  lda UART_STATUS
  and #$08          ; check rx buffer status flag
  beq keyboard_rx_wait
  lda UART_DATA
  rts
