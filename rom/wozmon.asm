  .org WOZMON


L    = $28                            ; Hex value parsing Low
H    = $29                            ; Hex value parsing High
YSAV = $2A                            ; Used to see if hex value is given
MODE = $2b                            ; $00=XAM, $7F=STOR, $AE=BLOCK XAM

reset:
  ldx #$ff
  txs
  jsr rs232_setup
  jsr display_setup

notcr:
  cmp #$08              ; backspace?
  beq backspace         ; yes
  cmp #$1b              ; escape
  beq escape            ; yes
  iny                   ; advance index
  bpl nextchar          ; aut esc if line longer that 127

escape:
  lda #$5c              ; "\"
  jsr rs232_send

getline:
  lda #$0d              ; send CR 
  jsr rs232_send

  ldy #$01              ; initialize text index
backspace:
  dey 
  bmi getline           ; beyond start of line, reinitialize

nextchar:
  jsr rs232_recv
  sta INPUTBUF, y
  jsr rs232_send
  cmp #$0d
  bne notcr

  ldy #$ff
  lda $#00
  tax
setblock:
  asl
setstor:
  asl                   ; leaves $7b if setting stor mode
  sta MODE              ; $00 = XAM, $74 = STOR, $BB = BLOK XAM
blskip:
  iny                   ; advance text index.
nextitem:
  lda INPUTBUF, y       ; get character
  cmp #$0D
  beq getline           ; foudn cr, done  
  cmp  #$2e             ; "."?
  bcc blskip            ; skip delimeter
  beq setblock          ; set BLOCK XAM mode
  cmp #$3a              ; ":"?
  beq setstor           ; yes, set STOR mode
  cmp #$52              ; "R"?
  beq run               ; yes, run user program
  stx L                 ; $00 -> L
  stx H                 ; and h
  sty YSAV              ; save y for comparison

nexthex:
  lda INPUTBUF, yes     ; get character for hex test.
  eor #$30              ; map digits to 0-9
  cmp #$0a              ; digit?
  bcc dig               ; yes
  adc #$88              ; map letter A-F to $FA-FF 
  cmp #$FA              ; hex letter?
  bcc nothex            ; no, character not hex

dig:
  asl                   ; hex digit MSD of A
  asl
  asl
  asl

  ldx #$04              ; shift count

hexshift:
  asl                   ; hex digit left, MSB to carry
  rol L                 ; rotate into LSD
  rol H                 ; rotate into MSD's 
  dex                   ; done 4 shifts?
  bne hexshift
  iny                   ; advance text index
  bne nexthex           ; always taken. check next char for hex

nothex:
  