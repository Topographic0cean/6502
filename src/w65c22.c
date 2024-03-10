#include <stdio.h>
#include <stdint.h>

#include "decoder.h"
#include "w65c22.h"
#include "display.h"

static uint8_t data = 0;
static uint8_t ddra = 0;
static uint8_t ddrb = 0;

int verbose = 0;

void w65c22_init(int v)
{
    verbose = v;
}

void io_register_a(uint8_t value)
{
    // a is wired to the control pins
    if (verbose)
        printf("io_register_a %x (%x)\n", value, ddra);
    data = value & ddra;
    if (ddra > 0)
        display_set_status((data & 0xE0) >> 5);
}

void io_register_b(uint8_t value)
{
    // b is wired to the display
    if (verbose)
        printf("io_register_b %x (%x)\n", value, ddrb);

    data = value & ddrb;
    if (ddrb > 0)
        display_write_data(data);
    if (ddrb != 0xFF)
        data = display_read_data();
}

void data_direction_a(uint8_t value)
{
    if (verbose)
        printf("data_direction_a %x\n", value);
    ddra = value;
}

void data_direction_b(uint8_t value)
{
    if (verbose)
        printf("data_direction_b %x\n", value);
    ddrb = value;
}

void w65c22_write(uint8_t address, uint8_t value)
{
    if (verbose)
        printf("w65c22_write: %x %x\n", address, value);
    switch (address)
    {
    case 0:
        io_register_b(value);
        break;
    case 1:
        io_register_a(value);
        break;
    case 2:
        data_direction_b(value);
        break;
    case 3:
        data_direction_a(value);
        break;
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
    case 12:
    case 13:
    case 14:
    case 15:
        break;
    }
}

uint8_t w65c22_read(uint8_t address)
{
    if (verbose)
        printf("w65c22_read: %x %x\n", address, data);
    switch (address)
    {
    case 0:
        io_register_b(0);
        return data;
    case 1:
        return display_read_data();
    case 2:
        return ddrb;
    case 3:
        return ddra;
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
    case 12:
    case 13:
    case 14:
    case 15:
        break;
    }
    return data;
}
