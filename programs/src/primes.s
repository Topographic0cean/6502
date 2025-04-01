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
PRIME       = $0E   ; Current prime which is also how many bits to skip when
                    ; marking not prime bits.  32 bit number
MASK        = $12   ; Holds current bit mask
BITADD      = $13   ; Holds the lower three bits of the PRIME to add when
                    ; skipping through the array
BYTEADD     = $14   ; Hold the number of bytes to skip.  16 bit number

; BIT_ARRAY starts at end of program

.org START
                JSR clear_bit_array

                LDA #$00
                STA NUMBIT
                LDA #<BIT_ARRAY
                STA BYTE
                LDA #>BIT_ARRAY
                STA BYTE+1
                
                LDA #$02
                STA PRIME
                LDA #$00
                STA PRIME+1
                STA PRIME+2
                STA PRIME+3

loop:
                JSR print_prime
                JSR move_to_next_prime
                JSR calc_prime
                JSR mark_non_primes
                LDA BYTE+1
                CMP #$50
                BEQ stop
                JSR five_secs
                JMP loop
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
                LDA PRIME
                sta HEAP
                LDA PRIME+1
                sta HEAP+1
                LDA PRIME+2
                sta HEAP+2
                LDA PRIME+3
                sta HEAP+3
                jsr DISPLAY_NUM
                rts

move_to_next_prime:
                ; increment the bit
                INC NUMBIT
                LDA NUMBIT
                CMP #$08
                BNE @test_prime_bit
                ; bit rolled over so increment the address
                LDA #$00
                STA NUMBIT
                CLC
                INC BYTE
                LDA BYTE
                BNE @test_prime_bit
                INC BYTE+1
@test_prime_bit:
                LDA NUMBIT
                ; create the bit mask
                JSR create_mask
                LDY #$00
                LDA MASK
                AND (BYTE),Y
                BNE move_to_next_prime
                RTS

calc_prime:
                ; Start with the byte address
                LDA BYTE
                STA PRIME
                LDA BYTE+1
                STA PRIME+1
                LDA #$00
                STA PRIME+2
                STA PRIME+3
                ; subtract the start of the prime bits
                SEC
                LDA PRIME
                SBC #<BIT_ARRAY 
                STA PRIME
                LDA PRIME+1
                SBC #>BIT_ARRAY 
                STA PRIME+1
                ; multiple by 16 (shift 4)
                LDY #$04
@mult_16:       CLC
                LDA PRIME
                ROL
                STA PRIME
                LDA PRIME+1
                ROL
                STA PRIME+1
                LDA PRIME+2
                ROL
                STA PRIME+2
                LDA PRIME+3
                ROL
                STA PRIME+3
                DEY
                BNE @mult_16
                ; numbits * 2 + 1
                CLC
                LDA NUMBIT
                ROL
                ADC #$01
                ; add to prime
                ADC PRIME
                STA PRIME
                LDA PRIME+1
                ADC #$00
                STA PRIME+1
                LDA PRIME+2
                ADC #$00
                STA PRIME+2
                LDA PRIME+3
                ADC #$00
                STA PRIME+3
                RTS
                
mark_non_primes:
                LDY #$00                ; setup curbit and cur byte
                LDA NUMBIT
                STA CURBIT
                LDA BYTE
                STA CURBYTE
                LDA BYTE+1
                STA CURBYTE+1
                LDA PRIME               ; setup the add bit and byte
                AND #$07
                STA BITADD
                LDA PRIME
                STA BYTEADD
                LDA PRIME+1
                STA BYTEADD+1
                LDA PRIME+2
                STA BYTEADD+2
                LDA PRIME+3
                STA BYTEADD+3
                CLC                     ; move off the lower 3 bits of byte add
                ROR BYTEADD+3
                ROR BYTEADD+2
                ROR BYTEADD+1
                ROR BYTEADD
                CLC       
                ROR BYTEADD+3
                ROR BYTEADD+2
                ROR BYTEADD+1
                ROR BYTEADD
                CLC                     ; move off the lower 3 bits
                ROR BYTEADD+3
                ROR BYTEADD+2
                ROR BYTEADD+1
                ROR BYTEADD
@do_mark:
                LDA CURBYTE+1           ; make sure we are not at the end
                CMP #$50
                BEQ @set_bit_done
                BPL @set_bit_done
                LDA CURBIT              ; create the bit mask for
                JSR create_mask         ; the current bit number
                LDA MASK
                ORA (CURBYTE),Y         ; apply it to the current byte
                STA (CURBYTE),Y
                CLC                     ; skip to next non prime
                LDA BITADD               
                ADC CURBIT
                STA CURBIT
                CMP #$08                ; did we go over 3 bits?
                BMI @add_upper_prime
                AND #$07                ; yes so mod 8 the curbit
                STA CURBIT              ; and add one to curbyte
                INC CURBYTE
                BNE @add_upper_prime
                INC CURBYTE+1
@add_upper_prime:
                CLC
                LDA CURBYTE
                ADC BYTEADD
                STA CURBYTE
                LDA CURBYTE+1
                ADC BYTEADD+1
                STA CURBYTE+1
                JMP @do_mark
@set_bit_done:
                rts

create_mask:
                ; Create a bit mask and store it into MASK
                ; bit number should be in A
                BEQ @zero_mask ; bit number is zero so just return 1
                TAX
                LDA #$01
@bit_mask_loop:
                ROL
                DEX
                BNE @bit_mask_loop
@create_mask_done:
                STA MASK
                RTS
@zero_mask:
                LDA #$01
                JMP @create_mask_done


five_secs:
                pha
                lda #$05
five_secs_loop:
                jsr ONE_SEC_DELAY
                dec
                bne five_secs_loop
                pla
                rts

BIT_ARRAY:      NOP
