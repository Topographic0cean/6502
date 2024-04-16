#pragma once

#include <stdint.h>

void w65c22_init(int verbose);
void w65c22_write(uint8_t address, uint8_t value);
uint8_t w65c22_read(uint8_t address);

void w65c22_tick();