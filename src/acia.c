#include <stdio.h>
#include <stdint.h>
#include <termios.h>
#include <unistd.h>
#include "acia.h"

#define ACIA_DATA 0
#define ACIA_STATUS 1
#define ACIA_CMD 2
#define ACIA_CTRL 3

static int verbose = 0;

extern void quit(int signum);

void acia_init(int v)
{
    verbose = v;
    setvbuf(stdin, NULL, _IONBF, 0);
    fflush(stdin);
    struct termios term;
    tcgetattr(fileno(stdin), &term);
    term.c_lflag &= ~ECHO;
    term.c_lflag &= ~ICANON;
    term.c_lflag &= ~ISIG;
    term.c_cc[VMIN] = 0;
    term.c_cc[VTIME] = 0;
    tcsetattr(fileno(stdin), TCSANOW, &term);
}

void acia_write(uint8_t address, uint8_t value)
{
    switch (address)
    {
    case ACIA_DATA:
        write(1, &value, 1);
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

static uint8_t last_char = 0;

uint8_t acia_read(uint8_t address)
{
    char c;
    size_t s;
    switch (address)
    {
    case ACIA_DATA:
        return last_char;
    case ACIA_STATUS:
        last_char = 0;
        s = read(0, &c, 1);
        if (s == 0)
            return 0x10;
        else if (c == 0x18) {
            quit(0);
        }
        else
        {
            if (c == 0x0A)
                last_char = 0x0D;
            else
                last_char = c;
            return 0x18;
        }
    case ACIA_CMD:
    case ACIA_CTRL:
        return 0;
    }
    return 0;
}
