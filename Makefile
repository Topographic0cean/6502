EXE = emulate6502

CC = gcc
LD = gcc

CFLAGS = -g -I/opt/homebrew/include
LDFLAGS =  -L/opt/homebrew/lib
LDLIBS = -lpopt -lncurses

# build directories
BIN = bin
OBJ = obj
SRC = src
ROMS = roms

SOURCES := $(wildcard $(SRC)/*.c $(SRC)/*.cc $(SRC)/*.cpp $(SRC)/*.cxx)

OBJECTS := \
	$(patsubst $(SRC)/%.c, $(OBJ)/%.o, $(wildcard $(SRC)/*.c)) \
	$(patsubst $(SRC)/%.cc, $(OBJ)/%.o, $(wildcard $(SRC)/*.cc)) \
	$(patsubst $(SRC)/%.cpp, $(OBJ)/%.o, $(wildcard $(SRC)/*.cpp)) \
	$(patsubst $(SRC)/%.cxx, $(OBJ)/%.o, $(wildcard $(SRC)/*.cxx))
ASM := $(wildcard $(ROM)/*.s)
# include compiler-generated dependency rules
DEPENDS := $(OBJECTS:.o=.d)

# compile C source
COMPILE.c = $(CC) $(DEPFLAGS) $(CFLAGS) $(CPPFLAGS) -c -o $@
LINK.o = $(LD) $(LDFLAGS)  $(OBJECTS) -o $@ $(LDLIBS)

.DEFAULT_GOAL = all

.PHONY: all $(ROMS)
all: $(BIN)/$(EXE) $(ROMS)

$(ROMS):
	make -C $(ROMS)

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
	make -C $(ROMS) clean

-include $(DEPENDS)

