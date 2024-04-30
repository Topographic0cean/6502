#include <stdio.h>
#include <stdint.h>
#include <termios.h>
#include "uart.h"

#define UART_DATA     0
#define UART_STATUS   1
#define UART_CMD      2
#define UART_CTRL     3

static int verbose = 0;

void uart_init(int v) {
    verbose = v;
    setvbuf(stdin, NULL, _IONBF, 0);
    fflush(stdin);
}

void uart_write(uint8_t address, uint8_t value) {
    switch(address) {
        case UART_DATA:
            if (value == 0x0d)
                putchar(0x0a);
            putchar(value);
            break;
        case UART_STATUS:
            // reset chip
            break;
        case UART_CMD:
            // command register
            break;
        case UART_CTRL:
            // control register
            break;
    }
}

uint8_t uart_read(uint8_t address) {
    uint8_t c;
    switch(address) {
        case UART_DATA:
        c = getchar();
        if (c == 0x0a) 
           return 0x0d;
        return c;
        case UART_STATUS:
            return 0x18;
        case UART_CMD:
            return 0x00;
        case UART_CTRL:
            return 0x00;
    }
    return 0x00;
}
