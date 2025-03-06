; 
; Uses the Sieve of Eratosthenes to print out primes.
; 
; 
.setcpu   "65C02"
.debuginfo
.include "../../rom/include/defines.s"

; Memory usage
;
; Zero Page


POS         = $04 ; bit number of the current prime
END         = $08 ; Last bit position we will consider
MARK        = $0C ; Current position to mark as not prime
PRIMES      = $10
MASK        = $14
ADDER       = $18

; Bit array starts at end of program


.org START
                ; clear bit arrray
                jsr clear_bit_array
                jmp stop


                lda #$20
                sta END
                lda #$00
                sta POS
                sta POS+1
                sta POS+2
                sta POS+3
                sta PRIMES
                sta PRIMES+1
                sta PRIMES+2
                sta PRIMES+3

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
                jsr mark_non_primes
                jsr move_to_next_prime
                jsr five_secs
                lda POS
                cmp END
                bne loop
stop:
                jmp stop

clear_bit_array:
                ; Set up zero-page pointer
                LDA #<BIT_ARRAY
                STA $FB
                LDA #>BIT_ARRAY
                STA $FC

                ; Clear memory loop
                LDA #$00        ; Load accumulator with zero

@clear_loop:
                STA ($FB)       ; Store zero at current address
                INC $FB         ; Increment low address
                BNE @skip_inc   ; If low address did not wrap do not inc high
                INC $FC         ; Increment high byte of address
@skip_inc:
                LDA $FB        ; Check if we've reached START_ROM
                CMP #<START_ROM
                BNE @clear_loop
                LDA $FC
                CMP #>START_ROM
                BNE @clear_loop

                RTS




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
                cmp #$40
                bmi mark_non_primes_loop
                rts
mark_non_primes_loop:
                sta ADDER
                lda MARK
                jsr set_bit
                lda MASK
                ora PRIMES
                sta PRIMES
                lda MASK+1
                ora PRIMES+1
                sta PRIMES+1
                lda MASK+2
                ora PRIMES+2
                sta PRIMES+2
                lda MASK+3
                ora PRIMES+3
                sta PRIMES+3
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
                lda #$00
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

BIT_ARRAY:      rts


