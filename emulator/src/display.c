#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

#include "ram.h"
#include "display.h"
#include "window.h"
#include "logger.h"

/*

*/

static uint8_t data = 0;
static uint8_t status = 0;

uint8_t poweron = 1;
uint8_t executing = 0;

uint8_t display = 0;
uint8_t cursor = 0;
uint8_t blink = 0;
uint8_t shift_cursor = 0;
uint8_t shift_display = 0;

uint8_t bits = 8;
uint8_t hi = 1;
uint8_t hi_data = 0;

#define FONT5_10 1
#define FONT5_8 2
uint8_t font;

#define MAX_LINES 2
#define MAX_CHARS 16
char LCD[MAX_LINES][MAX_CHARS + 1];
uint8_t lines = MAX_LINES;
uint8_t line = 0;
uint8_t pos = 0;

void display_clear()
{
    logger_log(LOGGER_IO, "display: clear\n");
    window_lcd_clear();
}

void display_write_char(uint8_t chr)
{
    logger_log(LOGGER_IO, "display: write char %x\n", chr);
    window_lcd_putc(chr);
}

void display_read_instruction()
{
    logger_log(LOGGER_IO, "display: read instruction %x\n", status);
    data = 0;
}
void display_set_ddram_address(uint8_t d)
{
    logger_log(LOGGER_IO, "display: set ddram address\n");
}
void display_set_cgram_address(uint8_t d)
{
    logger_log(LOGGER_IO, "display: set cgram address\n");
}
void display_function_set(uint8_t d)
{
    if (d & 0x10)
        bits = 8;
    else
        bits = 4;
    if (d & 0x08)
        lines = 2;
    else
        lines = 1;
    if (d & 0x04)
        font = FONT5_10;
    else
        font = FONT5_8;
    logger_log(LOGGER_IO, "display: function set bits=%d lines=%d font=%s\n", bits, lines, (font == FONT5_10) ? "5x10" : "5x8");
}

void display_shift(uint8_t d)
{
    logger_log(LOGGER_IO, "display: shift\n");
}

void display_display_ctl(uint8_t d)
{
    display = d & 0x04;
    cursor = d & 0x02;
    blink = d & 0x01;
    logger_log(LOGGER_IO, "display: ctl display %s cursor %s blink %s\n", d & 0x04 ? "on" : "off", d & 0x02 ? "on" : "off", d & 0x01 ? "on" : "off");
}

void display_mode_set(uint8_t d)
{
    shift_cursor = d & 0x02;
    shift_display = d & 0x01;
    logger_log(LOGGER_IO, "display: mode set %s %s\n", (shift_cursor) ? "cursor shift" : "cursor move", (shift_display) ? "display shift" : "display move");
}

void display_return_home()
{
    pos = 0;
    line = 0;
    window_lcd_home();
}

void display_write_instruction(uint8_t d)
{
    logger_log(LOGGER_IO, "display: write instruction %x\n", d);
    if (d & 0x80)
        display_set_ddram_address(d);
    else if (d & 0x40)
        display_set_cgram_address(d);
    else if (d & 0x20)
        display_function_set(d);
    else if (d & 0x10)
        display_shift(d);
    else if (d & 0x08)
        display_display_ctl(d);
    else if (d & 0x04)
        display_mode_set(d);
    else if (d & 0x02)
        display_return_home();
    else if (d & 0x01)
        display_clear();
    else
        logger_log(LOGGER_IO, "display: no op %d\n", d);
}

void display_set_status(uint8_t s)
{
    logger_log(LOGGER_IO, "display: set status from %x to %x\n", status, s);
    // transition from E=0 to E=1 triggers execution
    if (!(status & DISPLAY_E) && (s & DISPLAY_E))
        executing = 1;
    else
        executing = 0;
    status = s;
}

void display_write_four_bits(uint8_t control, uint8_t adjusted)
{
    if (hi)
    {
        logger_log(LOGGER_IO, "display: write four bit high %x\n", adjusted);
        hi_data = adjusted & 0xF0;
        hi = 0;
    }
    else
    {
        logger_log(LOGGER_IO, "display: write four bit low %x\n", adjusted);
        data = ((adjusted >> 4) & 0x0F) | hi_data;
        hi = 1;
        if (control & DISPLAY_RS)
            display_write_char(data);
        else
            display_write_instruction(data);
    }
}

void display_write_eight_bits(uint8_t control, uint8_t adjusted)
{
    if (control & DISPLAY_RS)
        display_write_char(adjusted);
    else
        display_write_instruction(adjusted);
}

/* Theses are the main entry points and all actions are trigger off of these. */

void display_write_data(uint8_t d)
{
    // We model the 4 bit wiring setup.
    // input bits 0-3 -> display 4-7
    // input bit 5 -> RS
    // input bit 6 -> RW
    // input bit 7 -> E
    uint8_t control = d & 0xE0;
    uint8_t adjusted = (d & 0x0f) << 4;
    display_set_status(d);
    if (executing)
    {
        logger_log(LOGGER_IO, "display: write data executing %x\n", d);
        if (control & DISPLAY_RW)
        {
            if (d & DISPLAY_RS)
                display_read_data();
            else
                display_read_instruction();
        }
        else
        {
            if (bits == 8)
                display_write_eight_bits(control, adjusted);
            else
                display_write_four_bits(control, adjusted);
        }
    }
    else
        logger_log(LOGGER_IO, "display: write data not executing %x\n", d);
}

uint8_t display_read_data()
{
    return data & 0x0f;
}

void display_init()
{
    display_clear();
}
