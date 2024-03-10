#pragma once

extern void ram_init(char* filename, int instruction_log);
extern void ram_write(uint16_t address, uint8_t value);
extern uint8_t ram_read(uint16_t address);
extern void dump_core();
