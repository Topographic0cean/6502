;  Various libary routines

.segment    "ROM"



; Delay for one second approximately
ONE_SEC_DELAY:
            phx
            phy
            pha
            ldx #$02
@delay_y:   
            ldy #$FF
@delay_a:
            lda #$FF
@loop_a:
            sbc #$01
            bne @loop_a
            dey
            bne @delay_a
            dex
            bne @delay_y
            pla
            ply
            plx
            rts

; Delay for one milisecond approximately
ONE_M_DELAY:
            phy
            pha
            ldy #$4D
@delay_m_a:
            lda #$FF
@loop_m_a:
            sbc #$01
            bne @loop_m_a
            dey
            bne @delay_m_a
            pla
            ply
            rts
