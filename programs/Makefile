all: counter.prg pi.prg hello.prg mult.prg

counter.prg: counter.s
	ca65 -o counter.o counter.s -l counter.list
	ld65 -C config counter.o -o counter.bin
	hexdump -C counter.bin | ./process > counter.prg

mult.prg: mult.s
	ca65 -o mult.o mult.s -l mult.list
	ld65 -C config mult.o -o mult.bin
	hexdump -C mult.bin | ./process > mult.prg

pi.prg: pi.s
	ca65 -o pi.o pi.s -l pi.list
	ld65 -C config pi.o -o pi.bin
	hexdump -C pi.bin | ./process > pi.prg

hello.prg: hello.s
	ca65 -o hello.o hello.s -l hello.list
	ld65 -C config hello.o -o hello.bin
	hexdump -C hello.bin | ./process > hello.prg

clean:
	/bin/rm -rf *.o *.bin *.prg

PHONY: all clean
