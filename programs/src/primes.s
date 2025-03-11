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
;
NUMBIT       = $04   ; Number of bit of current prime.  Starts at 1 (3)
CURBIT       = $05   ; Number of bit that we are marking at not prime
BYTE         = $06   ; Holds address of current 8 bit location of current prime 
CURBYTE     = $08   ; Holds address of current byte we marking at not prime
SKIP        = $0A   ; Current prime which is also how many bits to skip when
                    ; marking not prime bits.  32 bit number

; BIT_ARRAY starts at end of program


.org START
                JSR clear_bit_array

                LDA #$01
                STA NUMBIT
                LDA #<BIT_ARRAY
                STA BYTE
                LDA #>BIT_ARRAY
                STA BYTE+1

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
                jsr calc_skip
                jsr print_prime
                jsr mark_non_primes
                jsr move_to_next_prime
                jsr five_secs

                ; make sure BYTE is not greater that the max memory address
                
                bne loop
stop:
                jmp stop

clear_bit_array:
; Sets all bits in the prime array to 0
; $FB contains the starting address of the array and we set all bits until 
; we hit the ACIA region
                LDA #<BIT_ARRAY
                STA $FB
                LDA #>BIT_ARRAY
                STA $FC
                LDY #$00
@clear_loop:
                LDA #$00        ; Load accumulator with zero
                STA ($FB),Y    ; Store zero at current address
                INC $FB         ; Increment low address
                BNE @skip_inc   ; If low address did not wrap do not inc high
                INC $FC         ; Increment high byte of address
@skip_inc:
                LDA $FB        ; Check if we've reached START_ROM
                CMP #<ACIA
                BNE @clear_loop
                LDA $FC
                CMP #>ACIA
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


mark_non_primes:
@set_bit_done:
                rts

move_to_next_prime:
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


