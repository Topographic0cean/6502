#pragma once

#include <stdint.h>

void uart_init(int verbose);
void uart_write(uint8_t address, uint8_t value);
uint8_t uart_read(uint8_t address);
