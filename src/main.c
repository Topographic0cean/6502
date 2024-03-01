#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

#include "6502.h"
#include "ram.h"
#include "mmio.h"

int main(int argc, char *argv[])
{
    char* file = argv[1];
    int clocks = atoi(argv[2]);
    int sleep_time = atoi(argv[3]);
    ram_init(argv[1]);
    mmio_init();
    reset6502();
    printf("running %s for %d clocks\n",argv[1],clocks);
    for (int c = 0; c < clocks; c++) {
        exec6502(clocks);
        sleep(sleep_time);
    }
    exit(0);
}
