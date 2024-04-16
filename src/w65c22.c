#include <stdio.h>
#include <stdint.h>

#include "decoder.h"
#include "w65c22.h"
#include "display.h"
#include "6502.h"

/*
    Wiring Schematic

    IRQ     -> IRQ of 6502
    RW      -> RW of 6502
    D0-D7   -> Data Bus
    PA5     -> E  Display
    PA6     -> RW Display
    PA7     -> RS Display
    PB0-PB7 -> DB0-DB7 of Dislay



*/

static uint8_t data = 0;
static uint8_t ddra = 0;
static uint8_t ddrb = 0;
static uint8_t acr = 0;
static uint8_t ifr = 0;
static uint8_t ier = 0;
static uint16_t timer1 = 0;
static uint8_t timer1_running = 0;

int verbose = 0;

void w65c22_init(int v)
{
    verbose = v;
}

void set_t1_low(uint8_t value)
{
    timer1 = (value << 8) | (timer1 & 0xFF);
    if (verbose)
        printf("set t1 low %x\n", timer1);
}

void set_t1_high(uint8_t value)
{
    timer1 = (value) | (timer1 & 0xFF00);
    if (verbose)
        printf("set t1 high %x\n", timer1);
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

void start_timer1()
{
    timer1_running = 1;
}

void w65c22_tick()
{
    if (timer1_running)
    {
        timer1--;
        if (timer1 <= 0)
        {
            irq6502();
        }
    }
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

void t1_low(uint8_t value)
{
    if (verbose)
        printf("t1 low %x\n", value);
    set_t1_low(value);
}

void t1_high(uint8_t value)
{
    if (verbose)
        printf("t1 high %x\n", value);
    set_t1_high(value);
    start_timer1();
}

void acr_write(uint8_t value)
{
    if (verbose)
        printf("acr_write %x\n", value);
}

void ifr_write(uint8_t value)
{
    if (verbose)
        printf("ifr_write %x\n", value);
}

void ier_write(uint8_t value)
{
    if (verbose)
        printf("ier_write %x\n", value);
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
    case 4: // timer one Low
        t1_low(value);
        break;
    case 5: // timer one high counter
        t1_high(value);
        break;
    case 6: // time one low latch
    case 7: // timer one high latch
    case 8:
    case 9:
    case 0x0A:
    case 0x0B: // ACR
        acr_write(value);
        break;
    case 0x0C:
    case 0x0D: // IFR
        ifr_write(value);
        break;
    case 0x0E: // IER
        ier_write(value);
        break;
    case 0x0F:
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
