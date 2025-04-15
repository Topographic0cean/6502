.segment  "ROM"
IRQ:    JSR ACIA_READ
        RTI   

RESET:  CLD
        JSR ACIA_SETUP
        JSR VIA_SETUP
        LDA #$1b
        CLI 
.ifdef run_prime
        JMP START_PRIME
.endif
        JMP START_WOZMON


.segment    "INTERRUPT"
.word NMI
.word RESET
.word IRQ 
