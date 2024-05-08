#include <stdio.h>
#include <stdint.h>
#include <termios.h>
#include <unistd.h>
#include <pthread.h>
#include "acia.h"
#include "6502.h"

#define ACIA_DATA 0
#define ACIA_STATUS 1
#define ACIA_CMD 2
#define ACIA_CTRL 3

static int verbose = 0;
static pthread_t tid;
static char ch;

extern void quit(int signum);

void* read_keyboard(void* p) {
    //setvbuf(stdin, NULL, _IONBF, 0);
    //fflush(stdin);
    struct termios term;
    tcgetattr(fileno(stdin), &term);
    term.c_lflag &= ~ECHO;
    term.c_lflag &= ~ICANON;
    //term.c_lflag &= ~ISIG;
    //term.c_cc[VMIN] = 0;
    //term.c_cc[VTIME] = 0;
    tcsetattr(fileno(stdin), TCSANOW, &term);

    char c;
    size_t s;

    while(1) {
        s = read(0, &c, 1);
        if (s > 0) {
            switch(c) {
                case 0x18:
                    quit(0);
                    break;
                case 0x0A:
                    ch = 0x0D;
                    irq6502();
                    break;
                default:
                    ch = c;
                    irq6502();
            }
        }
    }

    pthread_exit(0);
}



void acia_init(int v)
{
    verbose = v;
    pthread_create(&tid, NULL, read_keyboard, NULL);
}

void acia_write(uint8_t address, uint8_t value)
{
    fflush(stdout);
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
