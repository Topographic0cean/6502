ASM := $(wildcard *.s)
LIB := $(wildcard lib/*.s)
MSB := $(wilcard msbasic/*.s)

.DEFAULT_GOAL = all

.PHONY: all clean
all: rom.bin

rom.bin: $(ASM) $(LIB) $(MSB)
	make -C msbasic

clean:
	$(RM) *.o */*.o *.bin bin/* *.list */*.list */*.lbl 
