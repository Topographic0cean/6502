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

#define FONT5_10 1
#define FONT5_8 2
uint8_t font;

#define MAX_LINES 2
#define MAX_CHARS 16
char LCD[MAX_LINES][MAX_CHARS + 1];
uint8_t lines = MAX_LINES;
uint8_t line = 0;
uint8_t pos = 0;

int verbose = 0;

void display_clear()
{
    if (verbose)
        log("display: clear\n");
    window_lcd_clear();
}

void display_write_char()
{
    log("display: write char %x\n", data);
    window_lcd_putc(data);
}

void display_read_instruction()
{
    if (verbose)
        log("display: read instruction %x\n", status);
    data = 0;
}
void display_set_ddram_address()
{
    if (verbose)
        log("display: set ddram address\n");
}
void display_set_cgram_address()
{
    if (verbose)
        log("display: set cgram address\n");
}
void display_function_set()
{
    if (data & 0x10)
        bits = 8;
    else
        bits = 4;
    if (data & 0x08)
        lines = 2;
    else
        lines = 1;
    if (data & 0x04)
        font = FONT5_10;
    else
        font = FONT5_8;
    if (verbose)
        log("display: function set bits=%d lines=%d font=%s\n", bits, lines, (font == FONT5_10) ? "5x10" : "5x8");
}

void display_shift()
{
    if (verbose)
        log("display: shift\n");
}

void display_display_ctl()
{
    display = data & 0x04;
    cursor = data & 0x02;
    blink = data & 0x01;
    if (verbose)
        log("display: ctl display %s cursor %s blink %s\n", data & 0x04 ? "on" : "off", data & 0x02 ? "on" : "off", data & 0x01 ? "on" : "off");
}

void display_mode_set()
{
    shift_cursor = data & 0x02;
    shift_display = data & 0x01;

    if (verbose)
        log("display: mode set %s %s\n", (shift_cursor) ? "cursor shift" : "cursor move", (shift_display) ? "display shift" : "display move");
}

void display_return_home()
{
    pos = 0;
    line = 0;
    window_lcd_home();
}

void display_write_instruction()
{
    if (verbose)
        log("display: write instruction %x\n", data);
    if (poweron)
    {
        if (data == 0x82)
        {
            log("display: poweron set 4 bits\n");
            bits = 4;
        }
        poweron = 0;
    }
    else if (data & 0x80)
        display_set_ddram_address();
    else if (data & 0x40)
        display_set_cgram_address();
    else if (data & 0x20)
        display_function_set();
    else if (data & 0x10)
        display_shift();
    else if (data & 0x08)
        display_display_ctl();
    else if (data & 0x04)
        display_mode_set();
    else if (data & 0x02)
        display_return_home();
    else if (data & 0x01)
        display_clear();
    else if (verbose)
        log("display: no op %d\n", data);
}

void display_set_status(uint8_t s)
{
    if (verbose)
        log("display: set status from %x to %x\n", status, s);
    // transition from E=0 to E=1 triggers execution
    if (!(status & DISPLAY_E) && (s & DISPLAY_E))
    {
        executing = 1;
    }
    else
    {
        executing = 0;
    }
    status = s;
}

void display_write_four_bits(uint8_t d)
{
    log("display: write four bit %x\n", d);
    if (hi)
    {
        data = d & 0x0f;
        hi = 0;
    }
    else
    {
        data = (data << 4) | (d & 0x0f);
        hi = 1;
        if (d & DISPLAY_RS)
            display_write_char();
        else
            display_write_instruction();
    }
}

/* Theses are the main entry points and all actions are trigger off of these. */

void display_write_data(uint8_t d)
{
    display_set_status(d);
    if (executing)
    {
        log("display: write data executing %x\n", d);
        if (d & DISPLAY_RW)
        {
            if (d & DISPLAY_RS)
                display_read_data();
            else
                display_read_instruction();
        }
        else
        {
            if (bits == 8)
            {
                data = d;
                if (d & DISPLAY_RS)
                    display_write_char();
                else
                    display_write_instruction();
            }
            else
                display_write_four_bits(d);
        }
    }
    else
        log("display: write data not executing %x\n", d);
}

uint8_t display_read_data()
{
    return data & 0x0f;
}

void display_init(int io_log)
{
    verbose = io_log;
    display_clear();
}
