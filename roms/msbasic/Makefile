
MSB := $(wildcard *.s)
LIB := $(wildcard ../lib/*.s)

../bin/msbasic.bin: $(MSB) $(LIB)
	ca65 -D eater msbasic.s -o msbasic.o -l msbasic.list
	ld65 -C eater.cfg msbasic.o -o ../bin/msbasic.bin -Ln msbasic.lbl

clean:
	/bin/rm *.o *.bin *.lbl tmp
