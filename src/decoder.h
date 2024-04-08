#pragma once

/* Address Layout
0x0000 - 0x00FF: Zero Page
0x0100 - 0x01FF: Stack
0x0200 - 0x02FF: Reserved for display.
0x0300 - 0x030a: Reserved for hex2dec

0x0400 - 0x6FFF: Free RAM
0x7000 - 0x7FFF: MMIO
    0111 0000 0001 0000 
    0x7010 - 0x7013:        MMIO1 W65C22
        Addressing bits 0-3 are used to select the register
    
0x8000 - 0xFFF9: ROM
0xFFFA - 0xFFFB: NMI Vector
0xFFFC - 0xFFFD: Reset Vector
0xFFFE - 0xFFFF: Interrupt Vector
*/

#include <stdint.h>

#define RAM_START 0x0000
#define RAM_END 0x6FFF
#define MMIO_START 0x7000
#define W65C22_REGISTERS 0x000F
#define MMIO_END 0x7FFF
#define ROM_START 0x8000
#define ROM_END 0xFFFF


extern uint8_t read6502(uint16_t address);
extern void write6502(uint16_t address, uint8_t value);