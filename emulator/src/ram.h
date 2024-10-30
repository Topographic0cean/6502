#pragma once

#include "options.h"

extern void ram_init(Options* options);
extern void ram_write(uint16_t address, uint8_t value);
extern uint8_t ram_read(uint16_t address);
extern void dump_core();
