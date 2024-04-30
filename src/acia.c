#include <stdio.h>
#include <stdint.h>
#include <termios.h>
#include "acia.h"

#define ACIA_DATA     0
#define ACIA_STATUS   1
#define ACIA_CMD      2
#define ACIA_CTRL     3

static int verbose = 0;

void acia_init(int v) {
    verbose = v;
    setvbuf(stdin, NULL, _IONBF, 0);
    fflush(stdin);
    struct termios term;
    tcgetattr(fileno(stdin),&term);
    term.c_lflag &= ~ECHO;
    term.c_lflag &= ~ICANON;
    tcsetattr(fileno(stdin), 0, &term);
}

void acia_write(uint8_t address, uint8_t value) {
    switch(address) {
        case ACIA_DATA:
            if (value == 0x0d)
                putchar(0x0a);
            putchar(value);
            fflush(stdout);
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

uint8_t acia_read(uint8_t address) {
    uint8_t c;
    switch(address) {
        case ACIA_DATA:
        c = getchar();
        fflush(stdin);
        if (c == 0x0a) 
           return 0x0d;
        return c;
        case ACIA_STATUS:
            return 0x18;
        case ACIA_CMD:
            return 0x00;
        case ACIA_CTRL:
            return 0x00;
    }
    return 0x00;
}
