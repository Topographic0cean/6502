#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "decoder.h"
#include "ram.h"

static FILE *ilog = NULL;
static char RAM[ROM_END + 1];

void ram_init(char *filename, int instruction_log)
{
    if (instruction_log)
        ilog = fopen("instructions.log", "w");

    // read the binary file ram.bin into RAM
    FILE *file = fopen(filename, "rb");
    if (file == NULL)
    {
        fprintf(stderr, "Error: Could not open %s\n", filename);
        exit(1);
    }
    size_t result = fread(RAM, 1, 0x10000, file);
    if (result != 0x10000)
    {
        fprintf(stderr, "Error: Could not read %s\n", filename);
        exit(1);
    }
    fclose(file);
}

void ram_write(uint16_t address, uint8_t value)
{
    RAM[address] = value;
}

uint8_t ram_read(uint16_t address)
{
    return RAM[address];
}

void dump_core()
{
    printf("dumping core\n");
    FILE *f = fopen("core.bin", "wb");
    if (f == NULL)
    {
        perror("fopen");
        exit(1);
    }
    fwrite(RAM, 1, 0x10000, f);
    fclose(f);
}