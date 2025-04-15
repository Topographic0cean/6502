
MSB := $(wildcard *.s)
LIB := $(wildcard ../lib/*.s)
BIN := ..

.PHONY: all

all: $(BIN)/rom.bin $(BIN)/rom_prime.bin

$(BIN)/rom.bin: $(MSB) $(LIB)
	ca65 -D eater msbasic.s -o msbasic.o -l msbasic.list
	ld65 -C ../rom.cfg msbasic.o -o $(BIN)/rom.bin -Ln msbasic.lbl

$(BIN)/rom_prime.bin: $(MSB) $(LIB)
	ca65 -D eater -D run_prime msbasic.s -o msbasic.o -l msbasic.list
	ld65 -C ../rom.cfg msbasic.o -o $(BIN)/rom_prime.bin -Ln msbasic.lbl

clean:
	/bin/rm *.o *.bin *.lbl tmp $(BIN)/rom.bin $(BIN)/rom_prime.bin
