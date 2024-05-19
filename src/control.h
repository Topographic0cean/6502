#pragma once

#include <stdint.h>

#include "options.h"

typedef struct Control  {
    uint8_t go;
    uint8_t irq;
    uint8_t nmi;
    uint8_t pause;
    uint8_t done;
    uint8_t step;
} Control;

extern void nmi_interrupt(int signum);
extern void maskable_interrupt(int signum);
extern void quit(int signum);
extern void cpu_pause();
extern void cpu_step();
extern void cpu_continue();
extern Control* control_init(Options* options);
