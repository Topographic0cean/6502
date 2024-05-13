#pragma once

#include <stdint.h>

void acia_init(int verbose);
void acia_write(uint8_t address, uint8_t value);
uint8_t acia_read(uint8_t address);
void acia_read_keyboard();