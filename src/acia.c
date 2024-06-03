#include <stdio.h>
#include <stdint.h>
#include <termios.h>
#include <unistd.h>
#include <ncurses.h>
#include "acia.h"
#include "6502.h"
#include "window.h"
#include "control.h"
#include "logger.h"

#define ACIA_DATA 0
#define ACIA_STATUS 1
#define ACIA_CMD 2
#define ACIA_CTRL 3

#define BUF_SIZE 16

static int verbose = 0;
static char input_buffer[BUF_SIZE];
static int read_buff = 0;
static int write_buff = 0;

int buff_not_full() {
    int w = (write_buff+1)%BUF_SIZE;
    if (w != read_buff)
        return 1;
    return 0;
}

uint16_t delay = 0;

void push_char(uint8_t c) {
    if (c == 0x7F) // Delete to backspace
        c = 0x08;
    if (c == 0x0A) // Carraige return to Line Feed
        c = 0x0D;
    input_buffer[write_buff] = c;
    write_buff = (write_buff+1)%BUF_SIZE;
    if (verbose) log("acia_read_keyboard %c (%d,%d)\n",c,read_buff,write_buff);
}

void acia_read_keyboard()
{
    int c;
    while (buff_not_full() && (c = getch()) != ERR)
    {
        switch (c)
        {
        case KEY_RESIZE:
            window_resize();
            break;
        case 0x02: // Control-B
            window_mem_backward();
            break;
        case 0x06: // Control-F
            window_mem_forward();
            break;
        case 0x07: // Control-G
            cpu_continue();
            break;
        case 0x0E: // Control-N
            cpu_step();
            break;
        case 0x10: // Control-P
            cpu_pause();
            break;
        case 0x18: // Control-X
            quit(0);
            break;
        default:
            push_char(c);
        }
    }
    if (!delay && read_buff != write_buff)
        maskable_interrupt(0);
    delay = (delay+1)%10000;
}

void acia_init(int v)
{
    verbose = v;
    if (verbose)
        log("ACIA verbose output\n");
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
        if (read_buff != write_buff) {
            char c = input_buffer[read_buff];
            read_buff = (read_buff+1)%BUF_SIZE;
            return c;
        }
        break;
    case ACIA_STATUS:
        return 0x10;
    case ACIA_CMD:
    case ACIA_CTRL:
        return 0;
    }
    return 0;
}
