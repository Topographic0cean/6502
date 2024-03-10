#pragma once

#include <stdint.h>

#define DISPLAY_E 0x04      // transition from 0 to 1 to trigger action
#define DISPLAY_RW 0x02     // 0 = write, 1 = read
#define DISPLAY_RS 0x01     // 0 = instruction, 1 = data

void display_init(int io_log);
void display_set_status(uint8_t status);
void display_write_data(uint8_t data);
uint8_t display_read_data();