
MSB := $(wildcard *.s)
LIB := $(wildcard ../lib/*.s)
BIN := ../../bin

$(BIN)/msbasic.bin: $(MSB) $(LIB)
	ca65 -D eater msbasic.s -o msbasic.o -l msbasic.list
	ld65 -C eater.cfg msbasic.o -o $(BIN)/msbasic.bin -Ln msbasic.lbl

clean:
	/bin/rm *.o *.bin *.lbl tmp $(BIN)/msbasic.bin
