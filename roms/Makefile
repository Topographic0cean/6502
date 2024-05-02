ASM := $(wildcard *.s)
LIB := $(wildcard lib/*.s)
MSB := $(wilcard msbasic/*.s)

.DEFAULT_GOAL = all

.PHONY: all clean
all: hello.bin counter.bin serial.bin wozmon.bin msbasic.bin


hello.bin: hello/hello.s $(LIB)
	ca65 -o hello/hello.o hello/hello.s -l hello/hello.list
	ld65 -C hello/hello.cfg hello/hello.o -o hello.bin

counter.bin: counter/counter.s $(LIB)
	ca65 -o counter/counter.o counter/counter.s -l counter/counter.list
	ld65 -C counter/counter.cfg counter/counter.o -o counter.bin

serial.bin: serial/serial.s $(LIB)
	ca65 -o serial/serial.o serial/serial.s -l serial/serial.list
	ld65 -C serial/serial.cfg serial/serial.o -o serial.bin

wozmon.bin: wozmon/wozmon.s $(LIB)
	ca65 -o wozmon/wozmon.o wozmon/wozmon.s -l wozmon/wozmon.list
	ld65 -C wozmon/wozmon.cfg wozmon/wozmon.o -o wozmon.bin

msbasic.bin: wozmon/wozmon.s $(LIB) $(MSB)
	make -C msbasic

clean:
	$(RM) *.o */*.o *.bin *.list
