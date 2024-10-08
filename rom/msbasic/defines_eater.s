; configuration
CONFIG_2A := 1

CONFIG_SCRTCH_ORDER := 2

; zero page
ZP_START0 = $00
; 2 bytes for the input buffer
; 10 bytes for the display
ZP_START1 = $0C
ZP_START2 = $16
ZP_START3 = $6C
ZP_START4 = $77

; extra/override ZP variables
USR				:= GORESTART ; XXX

; constants
SPACE_FOR_GOSUB := $3E
STACK_TOP		:= $FA
WIDTH			:= 40
WIDTH2			:= 30

RAMSTART2		:= $0400
