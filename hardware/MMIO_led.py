
code = bytearray([
    0xa9, 0xff,         # lda #$ff
    0x8d, 0x12, 0x70,   # sta $7012
    0xa9, 0x55,         # lda #$55
    0x8d, 0x10, 0x70,   # sta $7010
    0xa9, 0xaa,         # lda #$aa
    0x8d, 0x10, 0x70,   # sta $7010
    0x4c, 0x05, 0x80,   # jmp #8005
])

rom = code + bytearray([0xea] * (32*1024 - len(code)))

rom [0x7ffc] = 0x00
rom [0x7ffd] = 0x80


with open("rom.bin","wb") as f:
    f.write(rom);
    