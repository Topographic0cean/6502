; 
; Uses the Sieve of Eratosthenes to print out primes.
; 
.setcpu   "65C02"
.debuginfo
.include "../../rom/include/defines.s"

PSTARTLO = $2800        ; 4,000,000,000
PSTARTHI = $EE6B        

POS         = $04 ; Current base prime we are looking at
END         = $08 ; Last bit position we will consider
MARK        = $0C ; Current position to mark as not prime
PRIMES      = $10
MASK        = $14
ADDER       = $18

.org START
                lda #$08
                sta END
                lda #$00
                sta POS
                sta PRIMES

         ;      lda #$49
         ;      sta PRIMES
         ;      jsr move_to_next_prime


                jsr DISPLAY_CLEAR
                lda #$02
                sta HEAP
                lda #$00
                sta HEAP+1
                sta HEAP+2
                sta HEAP+3
                jsr DISPLAY_NUM
                jsr five_secs

loop:
                jsr print_prime
                brk 0
                jsr mark_non_primes
                jsr move_to_next_prime
                jsr five_secs
                lda POS
                cmp END
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
                ; POS is the bit of the current prime
                ; set the bit in A
                lda POS
                sta MARK
                jsr get_num
                cmp #$08
                bmi mark_non_primes_loop
                rts
mark_non_primes_loop:
                sta ADDER
                lda MARK
                jsr set_bit
                lda MASK
                ora PRIMES
                sta PRIMES
                lda MARK
                clc
                adc ADDER
                cmp END
                bmi @mark_not_done
                rts
@mark_not_done:
                sta MARK
                jmp mark_non_primes_loop

set_bit:
                tax
                clc
                lda #$01
                sta MASK
set_bit_loop:
                txa
                beq @set_bit_done 
                dex
                rol MASK 
                jmp set_bit_loop
@set_bit_done:
                rts

move_to_next_prime:
                inc POS
                lda POS
                cmp END
                beq @move_to_next_prime_done
                jsr set_bit
                lda MASK
                bit PRIMES
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




