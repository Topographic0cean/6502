all: pi.load

pi.load: pi.s
	ca65 -o pi.o pi.s -l pi.list
	ld65 -C config pi.o -o pi.bin
	hexdump -C pi.bin | ./process > pi.load

clean:
	/bin/rm -rf *.o *.bin *.load

PHONY: all clean
