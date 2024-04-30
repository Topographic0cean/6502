
LIB := $(wildcard *.s)

../msbasic.bin: $(LIB)
	ca65 -D eater msbasic.s -o msbasic.o
	ld65 -C eater.cfg msbasic.o -o ../msbasic.bin -Ln msbasic.lbl

clean:
	/bin/rm *.o *.bin *.lbl tmp