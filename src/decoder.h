#pragma once

/* Address Layout
0x0000 - 0x00FF: Zero Page
0x0100 - 0x01FF: Stack
0x0200 - 0x02FF: Reserved for input buffer
0x0300 - 0x030a: HEAP

ACIA = 0x5000
LCD = 0x6000

0x8000 - 0xFFF9: ROM
0xFFFA - 0xFFFB: NMI Vector
0xFFFC - 0xFFFD: Reset Vector
0xFFFE - 0xFFFF: Interrupt Vector
*/

#include <stdint.h>

#define RAM_START 0x0000
#define RAM_END 0x3FFF
#define ACIA_START 0x5000
#define ACIA_END 0x500F
#define LCD_START 0x6000
#define LCD_END 0x600F
#define ROM_START 0x8000
#define ROM_END 0xFFFF

extern uint8_t read6502(uint16_t address);
extern void write6502(uint16_t address, uint8_t value);