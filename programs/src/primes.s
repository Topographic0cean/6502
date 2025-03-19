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
NUMBIT      = $04   ; Number of bit of current prime.  Starts at 1 (3)
CURBIT      = $05   ; Number of bit that we are marking at not prime
BYTE        = $06   ; Holds address of current 8 bit location of current prime 
CURBYTE     = $08   ; Holds address of current byte we marking at not prime
BASENUM     = $0A   ; Hold odd number value of the first bit of the current byte
SKIP        = $0E   ; Current prime which is also how many bits to skip when
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
                
                LDA #$40
                LDY #$00
                STA (BYTE),Y

                LDA #$01
                STA BASENUM
                LDA #$00
                STA BASENUM+1
                STA BASENUM+2
                STA BASENUM+3

                LDA #$02
                STA SKIP
                LDA #$00
                STA SKIP+1
                STA SKIP+2
                STA SKIP+3
                LDY #$05
loop:
                PHY
                JSR print_prime
                JSR calc_skip
                JSR move_to_next_prime
                JSR mark_non_primes
                JSR five_secs
                PLY
                DEY
                BNE loop
stop:
                JMP stop

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
                JSR DISPLAY_CLEAR
                LDA SKIP
                sta HEAP
                LDA SKIP+1
                sta HEAP+1
                LDA SKIP+2
                sta HEAP+2
                LDA SKIP+3
                sta HEAP+3
                jsr DISPLAY_NUM
                rts


mark_non_primes:
                LDA BYTE
                STA CURBYTE
                LDA NUMBIT
                STA CURBIT
@do_mark:
                INC CURBYTE
                BNE @inc_curbyte_done
                INC CURBYTE+1
@inc_curbyte_done:
                LDA CURBYTE+1
                CMP #$50
                BNE @do_mark
@set_bit_done:
                rts

move_to_next_prime:
                ; increment the bit
                INC NUMBIT
                LDA NUMBIT
                CMP #$08
                BNE @move_to_next_prime_done
                ; bit rolled over so increment the address
                LDA #$00
                STA NUMBIT
                CLC
                LDA #$10
                ADC BASENUM
                STA BASENUM
                LDA #$00
                ADC BASENUM+1
                STA BASENUM+1
                INC BYTE
                BNE @move_to_next_prime_done
                INC BYTE+1
@move_to_next_prime_done:
                ; create the bit mask
                LDA NUMBIT
                TAX
                LDA #$01
@bit_mask_loop:
                DEX
                BEQ @test_number
                ROL
                jmp @bit_mask_loop
@test_number:
                BRK 0
                LDY #$00
                AND (BYTE),Y
                BNE move_to_next_prime
                RTS

calc_skip:
                ; Start with the bit number
                LDA NUMBIT
                STA SKIP
                LDA #$00
                STA SKIP+1
                STA SKIP+2
                STA SKIP+3
                ; Multiply by 2
                CLC
                ROL SKIP
                ROL SKIP+1
                ROL SKIP+2
                ROL SKIP+3
                ; add base odd number
                CLC
                LDA SKIP
                ADC BASENUM
                STA SKIP
                LDA SKIP+1
                ADC BASENUM+1
                STA SKIP+1
                LDA SKIP+2
                ADC BASENUM+2
                STA SKIP+2
                LDA SKIP+3
                ADC BASENUM+3
                STA SKIP+3
                RTS
                
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
