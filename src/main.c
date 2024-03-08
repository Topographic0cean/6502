#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

#include "6502.h"
#include "ram.h"
#include "mmio.h"



int main(int argc, char *argv[])
{
    char* file = argv[1];
    int clocks = atoi(argv[2]);
    int sleep_time = atoi(argv[3]);
    const struct timespec asleep = {sleep_time / 100, 
                                    (sleep_time % 100)*10000000};

    ram_init(argv[1]);
    mmio_init();
    reset6502();
    for (int c = 0; c < clocks; c++) {
        exec6502(clocks);
        if (sleep_time > 0)
            nanosleep(&asleep, NULL);
    }
    dump_core();
    exit(0);
}
