.setcpu   "65C02"
.debuginfo
.segment    "WOZMON"

.include "mem.s"

RESET:      cld
            jsr ACIA_SETUP
            jsr VIA_SETUP
            lda #$1b
            cli 

.ifdef RUN_PRIME
            jmp STARTPRIME
.endif

notcr:      cmp #$08              ; backspace?
            beq backspace         ; yes
            cmp #$1b              ; escape
            beq escape            ; yes
            iny                   ; advance index
            bpl nextchar          ; auto esc if line longer that 127

escape:     lda #$5c              ; "\"
            jsr MONCOUT

getline:    lda #$0D              ; send CR 
            jsr MONCOUT
            lda #$0A
            jsr MONCOUT

            ldy #$01              ; initialize text index
backspace:  dey 
            bmi getline           ; beyond start of line, reinitialize

nextchar:   jsr MONRDKEY 
            bcc nextchar
            jsr MONCOUT
            sta INPUTBUF, y
            cmp #$0D
            bne notcr

            ldy #$ff
            lda #$00
            tax
setblock:   asl
setstor:    asl                   ; leaves $7b if setting stor mode
            sta MODE              ; $00 = XAM, $74 = STOR, $BB = BLOK XAM
blskip:     iny                   ; advance text index.

nextitem:   lda INPUTBUF, y       ; get character
            cmp #$0D
            beq getline           ; found cr, done  
            cmp #$2e              ; "."?
            bcc blskip            ; skip delimeter
            beq setblock          ; set BLOCK XAM mode
            cmp #$3a              ; ":"?
            beq setstor           ; yes, set STOR mode
            cmp #$52              ; "R"?
            beq run               ; yes, run user program
            stx L                 ; $00 -> L
            stx H                 ; and h
            sty YSAV              ; save y for comparison

nexthex:    lda INPUTBUF, y       ; get character for hex test.
            eor #$30              ; map digits to 0-9
            cmp #$0a              ; digit?
            bcc dig               ; yes
            adc #$88              ; map letter A-F to $FA-FF 
            cmp #$FA              ; hex letter?
            bcc nothex            ; no, character not hex

dig:        asl                   ; hex digit MSD of A
            asl
            asl
            asl

            ldx #$04              ; shift count
hexshift:   asl                   ; hex digit left, MSB to carry
            rol L                 ; rotate into LSD
            rol H                 ; rotate into MSD
            dex                   ; done 4 shifts?
            bne hexshift
            iny                   ; advance text index
            bne nexthex           ; always taken. check next char for hex

nothex:     cpy YSAV              ; check if L, H empty (no hex digits)
            beq escape            ; yes, generate esc sequence
            bit MODE              ; test MODE byte
            bvc notstor           ; B6=0 is STOR, 1 is XAM and BLOCK XAM
            lda L                 ; LSDs of hex data 
            sta (STL,x)           ; store current store index
            inc STL               ; increment store index
            bne nextitem          ; get next item (no carry)
            inc STH               ; add carry to store index high order
tonextitem: jmp nextitem

run:        jmp (XAML)            ; run at current xam index

notstor:    bmi xamnext           ; b7= 0 for XAM, 1 for block xam

            ldx #$02  
setaddr:    lda L-1,x             ; copy hex data to
            sta STL-1,x           ; store index
            sta XAML-1,x          ; add to xam index
            dex
            bne setaddr

nxtprnt:    bne prdata            ; NE means no address to print
            lda #$0D              ; CR
            jsr MONCOUT
            lda #$0A              ; LF
            jsr MONCOUT
            lda XAMH              ; examine index high order byte
            jsr prbyte
            lda XAML              ; lower order examine index byte
            jsr prbyte            ; output it in hex format
            lda #$3a              ; ":"
            jsr MONCOUT

prdata:     lda #$20              ; blank
            jsr MONCOUT
            lda (XAML,x)          ; get data byte at examine index
            jsr prbyte
xamnext:    stx MODE              ; 0 -> MODE (xam mode)
            lda XAML
            cmp L                 ; compare examine index to hex data
            lda XAMH 
            sbc H 
            bcs tonextitem        ; not less so no more data to output

            inc XAML
            bne mod8chk           ; increment examine index
            inc XAMH

mod8chk:    lda XAML              ; check low order examine index byte
            and #$07              ; ofr mod 8 = 0
            bpl nxtprnt           ; always taken

prbyte:     pha
            lsr
            lsr
            lsr
            lsr
            jsr prhex
            pla

prhex:      and #$0f           ; mask lsd for hex print
            ora #$30          ; add "0"
            cmp #$3a          ; digit ?
            bcc echo
            adc #$06

echo:       jsr MONCOUT
            rts

NMI:        rti

SAVE:
LOAD:       rts

.include "acia.s"
.include "via.s"
.include "hextodec.s"
.include "vectors.s"
.include "math.s"
.include "primes.s"
.include "lib.s"
