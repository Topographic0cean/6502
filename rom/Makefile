ASM := $(wildcard src/*.s)
MSB := $(wilcard msbasic/*.s)

.DEFAULT_GOAL = all

.PHONY: all clean
all: rom.bin

rom.bin: $(ASM) $(MSB)
	make -C msbasic
	@./update_defines

clean:
	$(RM) *.o */*.o *.bin bin/* *.list */*.list */*.lbl 
