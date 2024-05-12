ASM := $(wildcard *.s)
LIB := $(wildcard lib/*.s)
MSB := $(wilcard msbasic/*.s)
BIN := ../bin

.DEFAULT_GOAL = all

.PHONY: all clean
all: $(BIN)/hello.bin $(BIN)/counter.bin $(BIN)/pi.bin $(BIN)/serial.bin $(BIN)/wozmon.bin $(BIN)/msbasic.bin

$(BIN)/hello.bin: hello/hello.s $(LIB)
	ca65 -o hello/hello.o hello/hello.s -l hello/hello.list
	ld65 -C hello/hello.cfg hello/hello.o -o $(BIN)/hello.bin

$(BIN)/counter.bin: counter/counter.s $(LIB)
	ca65 -o counter/counter.o counter/counter.s -l counter/counter.list
	ld65 -C counter/counter.cfg counter/counter.o -o $(BIN)/counter.bin

$(BIN)/pi.bin: pi/pi.s $(LIB)
	ca65 -o pi/pi.o pi/pi.s -l pi/pi.list
	ld65 -C pi/pi.cfg pi/pi.o -o $(BIN)/pi.bin


$(BIN)/serial.bin: serial/serial.s $(LIB)
	ca65 -o serial/serial.o serial/serial.s -l serial/serial.list
	ld65 -C serial/serial.cfg serial/serial.o -o $(BIN)/serial.bin

$(BIN)/wozmon.bin: wozmon/wozmon.s $(LIB)
	ca65 -o wozmon/wozmon.o wozmon/wozmon.s -l wozmon/wozmon.list
	ld65 -C wozmon/wozmon.cfg wozmon/wozmon.o -o $(BIN)/wozmon.bin

$(BIN)/msbasic.bin: wozmon/wozmon.s $(LIB) $(MSB)
	make -C msbasic

clean:
	$(RM) *.o */*.o *.bin bin/* *.list */*.list */*.lbl $(BIN)/*
