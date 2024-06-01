#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "decoder.h"
#include "ram.h"
#include "window.h"

static char RAM[ROM_END + 1];
static int verbose = 0;

static char status[128];

void outval(int addr, int val)
{
    if (addr >= 0 && addr <= 0x10000)
    {
        RAM[addr] = val;
    }
}

int atox(char *val)
{
    int x = 0;
    while (*val != '\0')
    {
        x = x * 16;
        if (*val >= '0' && *val <= '9')
            x += *val - '0';
        else if (*val >= 'A' && *val <= 'Z')
            x += 10 + *val - 'A';
        val++;
    }
    return x;
}

void load_program(char *filename)
{
    char line[128];
    char *cur;
    char ch;
    int addr = -1;

    FILE *file = fopen(filename, "r");
    if (file == NULL)
    {
        fprintf(stderr, "Error: Could not open %s\n", filename);
        return;
    }
    cur = line;
    while ((ch = fgetc(file)) != EOF)
    {
        if (ch == '\n' || ch == ' ')
        {
            if (cur > line) {
                *cur = '\0';
                int val = atox(line);
                outval(addr, val);
                addr++;
                cur = line;
            }
        }
        else if (ch == ':')
        {
            *cur = '\0';
            addr = atox(line);
            cur = line;
        }
        else
        {
            *cur = ch;
            cur++;
        }
    }

    fclose(file);
}

void ram_init(Options *options)
{
    memset(RAM, 0, sizeof(RAM));
    verbose = options->instructions;

    // read the binary file into high 32K of RAM
    FILE *file = fopen(options->rom, "rb");
    if (file == NULL)
    {
        fprintf(stderr, "Error: Could not open %s\n", options->rom);
        exit(1);
    }
    size_t result = fread(RAM + 0x8000, 1, 0x8000, file);
    if (result != 0x8000)
    {
        fprintf(stderr, "Error: Could not read %s\n", options->rom);
        exit(1);
    }
    fclose(file);

    if (*(options->load) != '\0')
        load_program(options->load);
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
    FILE *f = fopen("core.bin", "wb");
    if (f == NULL)
    {
        perror("fopen");
        exit(1);
    }
    fwrite(RAM, 1, 0x10000, f);
    fclose(f);
}