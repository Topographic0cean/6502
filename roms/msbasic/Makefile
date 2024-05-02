
MSB := $(wildcard *.s)
LIB := $(wildcard ../lib/*.s)

../msbasic.bin: $(MSB) $(LIB)
	ca65 -D eater msbasic.s -o msbasic.o
	ld65 -C eater.cfg msbasic.o -o ../msbasic.bin -Ln msbasic.lbl

clean:
	/bin/rm *.o *.bin *.lbl tmp