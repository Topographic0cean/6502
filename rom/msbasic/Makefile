
MSB := $(wildcard *.s)
LIB := $(wildcard ../lib/*.s)
BIN := ..

$(BIN)/msbasic.bin: $(MSB) $(LIB)
	ca65 -D eater msbasic.s -o msbasic.o -l msbasic.list
	ld65 -C ../rom.cfg msbasic.o -o $(BIN)/rom.bin -Ln msbasic.lbl

clean:
	/bin/rm *.o *.bin *.lbl tmp $(BIN)/msbasic.bin
