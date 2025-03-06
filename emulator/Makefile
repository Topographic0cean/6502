EXE = 6502emulator

CC = gcc
LD = gcc

CFLAGS = -g -I/opt/homebrew/include
LDFLAGS =  -L/opt/homebrew/lib
LDLIBS = -lpopt -lncurses

# build directories
BIN = bin
OBJ = obj
SRC = src

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

.PHONY: all $(ROM) $(PROGS)
all: $(BIN)/$(EXE) $(ROM) $(PROGS)

$(ROM):
	make -C $(ROM)

$(PROGS):
	make -C $(PROGS)

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


.PHONY: clean
clean:
	$(RM) -r $(OBJ)
	$(RM) -r $(BIN)
	$(RM) *.log *.bin

-include $(DEPENDS)

