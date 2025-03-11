BIN = ../bin
CONFIG = ../config
PROC = ../process
PROGS = $(patsubst %.s, $(BIN)/%.prg, $(wildcard *.s))

.PRECIOUS: $(BIN)/%.bin

all: $(PROGS)

$(BIN)/%.o: %.s
	@mkdir -p $(BIN)
	ca65 -o $@ $< -l $(BIN)/$(basename $@).list

$(BIN)/%.bin: $(BIN)/%.o
	ld65 -C $(CONFIG) $< -o $@ 

$(BIN)/%.prg: $(BIN)/%.bin
	hexdump -C $< | $(PROC) > $@

PHONY: all
