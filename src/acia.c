#include <stdio.h>
#include <stdint.h>
#include <termios.h>
#include <unistd.h>
#include <ncurses.h>
#include "acia.h"
#include "6502.h"
#include "window.h"
#include "control.h"

#define ACIA_DATA 0
#define ACIA_STATUS 1
#define ACIA_CMD 2
#define ACIA_CTRL 3

static int verbose = 0;
static char ch;

void acia_read_keyboard()
{
    int c = getch();
    switch (c)
    {
    case ERR:
        break;
    case KEY_RESIZE:
        window_resize();
        break;
    case 0x06:          // Control-F
        window_mem_forward();
        break;
    case 0x07:          // Control-G
        cpu_continue();
        break;
    case 0x0E:          // Control-N
        cpu_step();
        break;
    case 0x10:          // Control-P
        cpu_pause();
        break;
    case 0x18:          // Control-X
        quit(0);
        break;
    case 0x0A:          // Line Feed
        c = 0x0D;
    default:
        ch = c;
        maskable_interrupt(0);
    }
}

void acia_init(int v)
{
    verbose = v;
}

void acia_write(uint8_t address, uint8_t value)
{
    switch (address)
    {
    case ACIA_DATA:
        window_serial_putc(value);
        break;
    case ACIA_STATUS:
        // reset chip
        break;
    case ACIA_CMD:
        // command register
        break;
    case ACIA_CTRL:
        // control register
        break;
    }
}

uint8_t acia_read(uint8_t address)
{
    switch (address)
    {
    case ACIA_DATA:
        return ch;
    case ACIA_STATUS:
        return 0x10;
    case ACIA_CMD:
    case ACIA_CTRL:
        return 0;
    }
    return 0;
}
