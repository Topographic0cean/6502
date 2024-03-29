#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

#include "ram.h"
#include "display.h"

static FILE *iolog = NULL;

static uint8_t data = 0;
static uint8_t status = 0;

uint8_t display = 0;
uint8_t cursor = 0;
uint8_t blink = 0;
uint8_t shift_cursor = 0;
uint8_t shift_display = 0;

uint8_t bits;

#define FONT5_10 1
#define FONT5_8 2
uint8_t font;

#define MAX_LINES 2
#define MAX_CHARS 16
char LCD[MAX_LINES][MAX_CHARS + 1];
uint8_t lines = MAX_LINES;
uint8_t line = 0;
uint8_t pos = 0;

void display_write_data(uint8_t d)
{
    data = d;
}

uint8_t display_read_data()
{
    return data;
}

void display_clear()
{
    for (int i = 0; i < MAX_LINES; i++)
    {
        for (int j = 0; j < MAX_CHARS; j++)
        {
            LCD[i][j] = ' ';
        }
        LCD[i][MAX_CHARS] = '\0';
    }
    pos = 0;
    line = 0;
}

void display_write_char()
{
    LCD[line][pos] = data;
    pos++;
    if (pos >= MAX_CHARS)
    {
        pos = 0;
        line++;
        if (line >= lines)
        {
            line = 0;
        }
    }
    printf("\033[2J");
    printf("%s\n", LCD[0]);
    printf("%s\n", LCD[1]);
    fflush(stdout);
}

void display_read_instruction()
{
    if (iolog)
        fprintf(iolog, "display read instruction %x\n", status);
    data = 0;
}
void display_set_ddram_address()
{
    if (iolog)
        fprintf(iolog,"set ddram address\n");
    
}
void display_set_cgram_address()
{
   if (iolog)
        fprintf(iolog,"set cgram address\n");
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
    if (iolog)
        fprintf(iolog,"display function set bits=%d lines=%d font=%s\n", bits, lines, (font == FONT5_10) ? "5x10" : "5x8");
}

void display_shift()
{
    if (iolog)
        fprintf(iolog,"display shift\n");
}

void display_display_ctl()
{
    display = data & 0x04;
    cursor = data & 0x02;
    blink = data & 0x01;
    if (iolog)
        fprintf(iolog,"display display ctl display %s cursor %s blink %s\n", data & 0x04 ? "on" : "off", data & 0x02 ? "on" : "off", data & 0x01 ? "on" : "off");
}

void display_mode_set()
{
    shift_cursor = data & 0x02;
    shift_display = data & 0x01;

    if (iolog)
        fprintf(iolog,"display mode set %s %s\n", (shift_cursor) ? "cursor shift" : "cursor move", (shift_display) ? "display shift" : "display move");
}

void display_return_home()
{
    pos = 0;
    line = 0;
}

void display_write_instruction()
{
    if (iolog)
        fprintf(iolog,"display write instruction %d\n", data);
    if (data & 0x80)
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
    else
        if (iolog)
        fprintf(iolog, "display no op %d\n", data);
}

void display_set_status(uint8_t s)
{
    // transition from E=0 to E=1 triggers the read or write
    if (!(status & DISPLAY_E) && (s & DISPLAY_E))
    {
        if (s & DISPLAY_RW)
        {
            if (s & DISPLAY_RS)
                display_read_data();
            else
                display_read_instruction();
        }
        else
        {
            if (s & DISPLAY_RS)
                display_write_char();
            else
                display_write_instruction();
        }
    }
    status = s;
}

void display_init(int io_log)
{
    if (io_log)
    {
        iolog = fopen("display.log", "w");
    }
    display_clear();
}
