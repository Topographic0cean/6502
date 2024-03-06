#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "mmio.h"



static FILE* ilog = NULL;
static char RAM[0xFFFF];

void ram_init(char* filename) {
    ilog = fopen("instructions.log","w");

    // read the binary file ram.bin into RAM
    FILE *file = fopen(filename, "rb");
    if (file == NULL) {
        fprintf(stderr, "Error: Could not open ram.bin\n");
        exit(1);
    }
    size_t result = fread(RAM, 1, 0xFFFF, file);
    if (result != 0xFFFF) {
        fprintf(stderr, "Error: Could not read ram.bin\n");
        exit(1);
    }
    fclose(file);
}

uint8_t read6502(uint16_t address)
{
    if (address < 0 || address > 0xFFFF) {
        fprintf(stderr,"READ: invalid memory address: %4x\n", address);
        exit(1);
    }

    uint8_t result = RAM[address];
    if (ilog != NULL)
        fprintf(ilog,"%4x r %2x\n", address, result);
    return result;
}

void write6502(uint16_t address, uint8_t value)
{
    if (address < 0 || address > 0xFFFF) {
        fprintf(stderr,"WRITE: invalid memory address: %4x\n", address);
        exit(1);
    }
    if (ilog != NULL)
        fprintf(ilog,"%4x W %2x\n", address, value);
    RAM[address] = value;
    mmio_write(address, value);
}
