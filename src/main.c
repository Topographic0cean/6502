#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

#include "6502.h"
#include "ram.h"
#include "mmio.h"

void nmi_interrupt(int signum)
{
    printf("nmi\n");
    nmi6502();
}

void maskable_interrupt(int signum)
{
    irq6502();
}

void quit(int signum)
{
    exit(0);
}

void setup_interrupt_handlers()
{
    signal(SIGABRT, nmi_interrupt);
    signal(SIGINT, quit);
    signal(SIGTERM, maskable_interrupt);
    signal(SIGSEGV, dump_core);
}

int main(int argc, char *argv[])
{
    char *file = argv[1];
    int clocks = atoi(argv[2]);
    int sleep_time = atoi(argv[3]);
    struct timespec asleep = {0, sleep_time*1000000};
    if (sleep_time == 0) {
        asleep.tv_nsec = 1;
    }

    setup_interrupt_handlers();
    ram_init(argv[1]);
    mmio_init();
    reset6502();

    int c = 0;
    while (clocks == 0 || c < clocks)
    {
        step6502();
        if (sleep_time > 0)
            nanosleep(&asleep, NULL);
        c++;
    }

    exit(0);
}
