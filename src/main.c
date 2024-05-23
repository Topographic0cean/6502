#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <popt.h>

#include "6502.h"
#include "ram.h"
#include "w65c22.h"
#include "acia.h"
#include "display.h"
#include "window.h"
#include "options.h"
#include "control.h"

Options *options;
Control *controls;

void initialize()
{
    controls = control_init(options);
    window_init();
    ram_init(options);
    w65c22_init(options->verbose);
    acia_init(options->verbose);
    display_init(options->io);
    reset6502();
}

int main(int argc, const char *argv[])
{
    struct timespec asleep;
    struct timespec mssleep;

    options = process_options(argc, argv);
    initialize();

    mssleep.tv_sec = 0;
    mssleep.tv_nsec = 100000000;

    int c = 0;
    while (options->clocks == 0 || c < options->clocks)
    {
        if (controls->nmi == 1)
        {
            nmi6502();
            controls->nmi = 0;
        }
        if (controls->irq == 1)
        {
            irq6502();
            controls->irq = 0;
        }
        if (controls->done == 1)
        {
            break;
        }
        if (controls->go) {
            controls->pause = 0;
            controls->go = 0;
        }
        if (controls->pause == 0 || controls->step) {
            step6502();
            w65c22_tick();
            asleep.tv_sec = 0;
            asleep.tv_nsec = options->sleep;
            nanosleep(&asleep, NULL);
            controls->step = 0;
        }
        else {
            window_show_state();
            nanosleep(&mssleep, NULL);
        }
        acia_read_keyboard();
        c++;
    }
    if (options->core == 1)
        dump_core();
    
    window_shutdown();

    exit(0);
}
