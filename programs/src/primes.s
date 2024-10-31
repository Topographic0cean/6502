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
PRIMES    = $10

.org START
                jsr DISPLAY_CLEAR
                lda #$02
                sta HEAP
                lda #$00
                sta HEAP+1
                sta HEAP+2
                sta HEAP+3
                jsr DISPLAY_NUM
                jsr five_secs

                lda #$08
                sta END
                lda #$00
                sta POS
                sta PRIMES
loop:
                jsr print_prime
                jsr mark_non_primes
                jsr move_to_next_prime
                jsr five_secs
                lda POS
                cmp END
                ;bne loop
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
                ; POS is the bit of the current prime
                ; set the bit in A
                lda POS
                sta MARK
mark_non_primes_loop:
                jsr set_bit
                ora PRIMES
                sta PRIMES
                lda MARK
                cmp END
                beq @mark_non_primes_done
                clc
                adc #$03
                sta MARK
                jmp mark_non_primes_loop
@mark_non_primes_done:
                rts

set_bit:
                brk 0
                lda MARK
                tax
                lda #80
set_bit_loop:
                asl 
                dex
                beq @set_bit_done
                jmp set_bit_loop
@set_bit_done:
                rts

move_to_next_prime:
                inc POS
                cmp END
                beq @move_to_next_prime_done
                sta MARK
                jsr set_bit
                and PRIMES
                bne move_to_next_prime
@move_to_next_prime_done:
                rts
                
five_secs:
                pha
                lda #$05
five_secs_loop:
                jsr ONE_SEC_DELAY
                dec
                bne five_secs_loop
                pla
                rts




