ASM := $(wildcard *.s)

.DEFAULT_GOAL = all

.PHONY: all clean
all: hello.bin counter.bin serial.bin

hello.bin: hello/hello.s
	ca65 -o hello/hello.o hello/hello.s -l hello.list
	ld65 -C hello/hello.cfg hello/hello.o -o hello.bin

counter.bin: counter/counter.s
	ca65 -o counter/counter.o counter/counter.s -l counter.list
	ld65 -C counter/counter.cfg counter/counter.o -o counter.bin

serial.bin: serial/serial.s
	ca65 -o serial/serial.o serial/serial.s -l serial.list
	ld65 -C serial/serial.cfg serial/serial.o -o serial.bin

clean:
	$(RM) *.o */*.o *.bin *.list
