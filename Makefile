
.PHONY: all emulator rom programs clean
all: emulator rom programs

emulator:
	make -C $@

rom:
	make -C $@

programs:
	make -C $@

clean:
	make -C rom clean
	make -C emulator clean
	make -C programs clean


