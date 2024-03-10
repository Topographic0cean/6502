#include <stdio.h>
#include <stdlib.h>

#include "decoder.h"
#include "ram.h"
#include "w65c22.h"

uint8_t read6502(uint16_t address)
{
    if (address >= RAM_START && address <= RAM_END || address >= ROM_START && address <= ROM_END)
    {
        return ram_read(address);
    }
    else if (address >= MMIO_START && address <= MMIO_END)
    {
        uint8_t reg = address & W65C22_REGISTERS;
        if (address == MMIO_START|| reg > 0)
            return w65c22_read(reg);
    }
    else
    {
        fprintf(stderr, "READ: invalid memory address: %4x\n", address);
        exit(1);
    }
    return 0;
}

void write6502(uint16_t address, uint8_t value)
{
    if (address >= RAM_START && address <= RAM_END || address >= ROM_START && address <= ROM_END)
    {
        return ram_write(address, value);
    }
    else if (address >= MMIO_START && address <= MMIO_END)
    {
        uint8_t reg = address & W65C22_REGISTERS;
        if (address == MMIO_START|| reg > 0)
            return w65c22_write(reg, value);
    }
    else
    {
        fprintf(stderr, "WRITE: invalid memory address: %4x\n", address);
        exit(1);
    }
}