PCR = (LCD+$0C)
IER = (LCD+$0E)

interrupt_setup:
    lda #$82    ; set CA1
    sta IER
    lda #$00    ; set CA1 to negative active edge
    sta PCR
    rts
