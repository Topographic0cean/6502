; 
; Uses the Sieve of Eratosthenes to print out primes.
; 
.setcpu   "65C02"
.debuginfo
.include "../../rom/include/defines.s"

PSTARTLO = $2800        ; 4,000,000,000
PSTARTHI = $EE6B        

POS       = $04 ; Current base prime we are looking at
END       = $08 ; Last bit position we will consider
MARK      = $0C ; Current position to mark as not prime

.org START
                jsr DISPLAY_CLEAR
                lda #$02
                sta HEAP
                lda #$00
                sta HEAP+1
                sta HEAP+2
                sta HEAP+3
                jsr DISPLAY_NUM
                jsr ONE_SEC_DELAY

                lda #$07
                sta END
                lda #$00
                sta POS
loop:
                jsr print_prime
                jsr mark_non_primes
                jsr move_to_next_prime
                bne loop
stop:
                jmp stop


print_prime:
                jsr DISPLAY_CLEAR
                jsr get_num
                sta HEAP
                lda #$00
                sta HEAP+1
                sta HEAP+2
                sta HEAP+3
                jsr DISPLAY_NUM
                rts

get_num:
                clc
                lda POS
                adc POS
                adc #$03
                rts

mark_non_primes:
                rts

move_to_next_prime:
                inc POS
                cmp #$07
                rts
                





