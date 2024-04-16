EXE = emulate6502

CC = gcc
LD = gcc

CFLAGS =  -g
LDFLAGS = 
LDLIBS = -lpopt

# build directories
BIN = bin
OBJ = obj
SRC = src
ROM = rom

SOURCES := $(wildcard $(SRC)/*.c $(SRC)/*.cc $(SRC)/*.cpp $(SRC)/*.cxx)

OBJECTS := \
	$(patsubst $(SRC)/%.c, $(OBJ)/%.o, $(wildcard $(SRC)/*.c)) \
	$(patsubst $(SRC)/%.cc, $(OBJ)/%.o, $(wildcard $(SRC)/*.cc)) \
	$(patsubst $(SRC)/%.cpp, $(OBJ)/%.o, $(wildcard $(SRC)/*.cpp)) \
	$(patsubst $(SRC)/%.cxx, $(OBJ)/%.o, $(wildcard $(SRC)/*.cxx))

# include compiler-generated dependency rules
DEPENDS := $(OBJECTS:.o=.d)

# compile C source
COMPILE.c = $(CC) $(DEPFLAGS) $(CFLAGS) $(CPPFLAGS) -c -o $@
LINK.o = $(LD) $(LDFLAGS)  $(OBJECTS) -o $@ $(LDLIBS)

.DEFAULT_GOAL = all

.PHONY: all
all: $(BIN)/$(EXE) rom.bin

rom.bin: $(ROM)/rom.asm
	vasm -Fbin -dotdir  -L rom.list -o rom.bin $(ROM)/rom.asm

$(BIN)/$(EXE): $(SRC) $(OBJ) $(BIN) $(OBJECTS)
	$(LINK.o)

$(SRC):
	mkdir -p $(SRC)

$(OBJ):
	mkdir -p $(OBJ)

$(BIN):
	mkdir -p $(BIN)

$(OBJ)/%.o:	$(SRC)/%.c
	$(COMPILE.c) $<

# execute the program
.PHONY: run
run: $(BIN)/$(EXE)
	./$(BIN)/$(EXE) $(OBJ)/rom.bin 50 10

.PHONY: clean
clean:
	$(RM) -r $(OBJ)
	$(RM) -r $(BIN)
	$(RM) *.log *.bin

-include $(DEPENDS)

