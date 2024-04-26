#include <stdio.h>
#include <stdlib.h>

#include "decoder.h"
#include "ram.h"
#include "w65c22.h"
#include "uart.h"

uint8_t read6502(uint16_t address)
{
    uint8_t reg = address & 0x0F;
    if (address >= RAM_START && address <= RAM_END || address >= ROM_START && address <= ROM_END)
    {
        return ram_read(address);
    }
    else if (address >= UART_START && address <= UART_END)
    {
        return uart_read(reg);
    }
    else if (address >= LCD_START && address <= LCD_END)
    {
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
    uint8_t reg = address & 0x0f;
    if (address >= RAM_START && address <= RAM_END || address >= ROM_START && address <= ROM_END)
    {
        return ram_write(address, value);
    }
    else if (address >= LCD_START && address <= LCD_END)
    {
        return w65c22_write(reg, value);
    }
    else if (address >= UART_START && address <= UART_END)
    {
        return uart_write(reg, value);
    }
    else
    {
        fprintf(stderr, "WRITE: invalid memory address: %4x\n", address);
        exit(1);
    }
}