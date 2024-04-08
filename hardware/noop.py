
rom = bytearray([0xea] * 32*1024)

with open("rom.bin","wb") as f:
    f.write(rom);
    
