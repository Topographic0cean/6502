#include <popt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#include "6502.h"
#include "acia.h"
#include "control.h"
#include "display.h"
#include "logger.h"
#include "options.h"
#include "ram.h"
#include "w65c22.h"
#include "window.h"

Options *options;
Control *controls;

extern uint16_t pc;
extern uint8_t sp, a, x, y, status;

void check_instruction() {
    if (status & FLAG_BREAK) {
        status &= ~FLAG_BREAK;
        controls->pause = 1;
    }
}

void initialize(int argc, const char *argv[]) {
    options = process_options(argc, argv);
    if (options->keys) {
        printf("keyboard controls:  \n");
        printf("\tctl-b    Scroll backward in memory,\n");
        printf("\tctl-f    Scroll forward in memory,\n");
        printf("\tctl-g    Continue program,\n");
        printf("\tctl-n    Step one instruction,\n");
        printf("\tctl-m    Set the memory display location,\n");
        printf("\tctl-p    Pause program,\n");
        printf("\tctl-r    Reset 6502,\n");
        printf("\tctl-x    Exit emulator.\n");
        exit(0);
    }
    controls = control_init(options);
    logger_init(options->verbose);
    window_init();
    ram_init(options);
    w65c22_init();
    acia_init();
    display_init();
    hookexternal(check_instruction);
    reset6502();
}

void shutdown() {
    window_shutdown();
    logger_close();
}

int handle_controls() {
    struct timespec asleep;
    struct timespec mssleep;
    mssleep.tv_sec = 0;
    mssleep.tv_nsec = 100000000;
    asleep.tv_sec = 0;
    asleep.tv_nsec = options->sleep;

    if (controls->reset == 1) {
        logger_log(LOGGER_IO, "===== reset ===== \n");
        reset6502();
        controls->reset = 0;
    }
    if (controls->nmi == 1) {
        nmi6502();
        controls->nmi = 0;
    }
    if (controls->irq == 1) {
        irq6502();
        controls->irq = 0;
    }
    if (controls->done == 1) {
        return 0;
    }
    if (controls->go) {
        controls->pause = 0;
        controls->go = 0;
    }
    if (controls->memset) {
        controls->memset = 0;
        if (controls->pause == 1)
            window_set_mem();
    }
    if (controls->pause == 0 || controls->step) {
        step6502();
        w65c22_tick();
        nanosleep(&asleep, NULL);
        controls->step = 0;
    } else {
        window_show_state();
        nanosleep(&mssleep, NULL);
    }
    return 1;
}

int main(int argc, const char *argv[]) {
    initialize(argc, argv);

    int c = 0;
    while (options->clocks == 0 || c < options->clocks) {
        if (handle_controls() == 0) break;
        acia_read_keyboard();
        c++;
    }
    if (options->core == 1) dump_core();

    shutdown();
    exit(0);
}
