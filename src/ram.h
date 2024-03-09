#pragma once

/* RAM Layout
0x0000 - 0x00FF: Zero Page
0x0100 - 0x01FF: Stack
0x0200 - 0x02FF: Reserved for display.
0x0300 - 0x030a: Reserved for hex2dec

0x0400 - 0x6FFF: Free RAM
0x7000 - 0x7FFF: MMIO
0x8000 - 0xFFF9: ROM
0xFFFA - 0xFFFB: NMI Vector
0xFFFC - 0xFFFD: Reset Vector
0xFFFE - 0xFFFF: Interrupt Vector
*/

#define RAM_SIZE (32*1024)
#define ROM_SIZE (32*1024)

#define RAM_START 0x0000
#define RAM_END 0x6FFF

#define ROM_START 0x8000
#define ROM_END 0xFFFF

#define MMIO_START 0x7000
#define MMIO_END 0x7FFF

extern void ram_init(char* filename, int instruction_log);
extern void ram_fill(uint8_t size, uint16_t reset_vector);
extern uint8_t read6502(uint16_t address);
extern void write6502(uint16_t address, uint8_t value);
extern void dump_core();
