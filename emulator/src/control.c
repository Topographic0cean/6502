#include "control.h"

#include <signal.h>

#include "window.h"

static Control control;

void nmi_interrupt(int signum) { control.nmi = 1; }

void maskable_interrupt(int signum) { control.irq = 1; }

void quit(int signum) { control.done = 1; }

void cpu_reset() { control.reset = 1; }
void cpu_pause() { control.pause = 1; }
void cpu_step() { control.step = 1; }
void cpu_continue() { control.go = 1; }

void set_memory() { control.memset = 1; }

void setup_interrupt_handlers() {
    signal(SIGUSR2, nmi_interrupt);
    signal(SIGINT, quit);
    signal(SIGQUIT, quit);
    signal(SIGUSR1, maskable_interrupt);
}

Control *control_init(Options *options) {
    setup_interrupt_handlers();
    control.go = 0;
    control.irq = 0;
    control.nmi = 0;
    control.pause = options->paused;
    control.reset = 0;
    control.done = 0;
    control.step = 0;
    return &control;
}
