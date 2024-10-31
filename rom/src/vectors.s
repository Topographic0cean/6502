

.segment  "ROM"
IRQ:
        pla             ; status register is top of stack
        pha             ; copy it into A
        bit #$01        ; BREAK set?
        beq @return
        jsr ACIA_READ
@return:
        rti   
        
.segment    "INTERRUPT"
.word NMI
.word RESET
.word IRQ 
