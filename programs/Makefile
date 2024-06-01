all: pi.prg

pi.prg: pi.s
	ca65 -o pi.o pi.s -l pi.list
	ld65 -C config pi.o -o pi.bin
	hexdump -C pi.bin | ./process > pi.prg

clean:
	/bin/rm -rf *.o *.bin *.prg

PHONY: all clean
