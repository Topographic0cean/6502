DISPLAY   = $0000 ; 2 byte address of string
STACK     = $0100 ; 256 byte stack
INPUTBUF  = $0200 ; Wozmon input buffer
HEAP      = $0300
CLOCK     = $0400 ; 2 bytes
;LCD       = $7010
LCD       = $6000
;UART      = $7040
UART      = $5000
ROM       = $8000
WOZMON    = $FF00
VECTORS   = $FFFA

  .org ROM

start_message:
  lda hello,x
  beq end_message
 ; pha
  jsr rs232_send
 ; pla
 ; jsr display_putc
  inx
  jmp start_message
end_message:
  lda #$0D
  jsr rs232_send
  lda #$0A
  jsr rs232_send
  jsr rs232_recv
 ; pha
 ; jsr display_clear
 ; pla
keyboard_loop:
 ; pha
  jsr rs232_send
 ; pla
 ; jsr display_putc
  jsr rs232_recv
  jmp keyboard_loop
  
clock_loop:
  lda #$00
  sta CLOCK
  sta CLOCK+1
  sei
  lda CLOCK
  sta HEAP
  lda CLOCK + 1
  sta HEAP + 1
  cli
  jsr hextodec
  lda #$04
  sta DISPLAY
  lda #$03
  sta DISPLAY+1
  jsr display_string
  rts

do_nothing:
  jmp do_nothing

nmi:
irq:
  inc CLOCK
  bne vector_exit
  inc CLOCK + 1
vector_exit:
  bit PORTA
  rti

hello: .string "ROS 0.0"

  .include "display.asm"
  .include "hextodec.asm"
  .include "interrupts.asm"
  .include "rs232.asm"
  .include "wozmon.asm"



  .org VECTORS
  .word nmi
  .word WOZMON
  .word irq