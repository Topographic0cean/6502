.segment  "ROM"
IRQ:
        jsr ACIA_READ
        rti   
        
.segment    "INTERRUPT"
.word NMI
.word RESET
.word IRQ 
