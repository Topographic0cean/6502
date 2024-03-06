#pragma once
// We combine the WD65C22 IO and LCD display into a single
// file.

extern void mmio_init();
extern void mmio_write(uint16_t address, uint8_t value);

