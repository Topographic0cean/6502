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
#include "logger.h"

Options *options;
Control *controls;

void initialize(int argc, const     char* argv[])
{
    options = process_options(argc, argv);
    controls = control_init(options);
    logger_init(options->instructions|options->io);
    window_init();
    ram_init(options);
    w65c22_init(options->io);
    acia_init(options->io);
    display_init(options->io);
    reset6502();
}

void shutdown() {
    window_shutdown();
    logger_close();
}

int main(int argc, const char *argv[])
{
    struct timespec asleep;
    struct timespec mssleep;

    initialize(argc,argv);

    mssleep.tv_sec = 0;
    mssleep.tv_nsec = 100000000;
    asleep.tv_sec = 0;
    asleep.tv_nsec = options->sleep;

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

    shutdown();
    exit(0);
}
