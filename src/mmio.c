#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

#include "mmio.h"

#define LED_LIGHTS 0
#define LCD_DISPLAY 1

#define LCD_PORTB 0xB000
#define LCD_PORTA 0xB001
#define LCD_DDRB 0xB002
#define LCD_DDRA 0xB003

#define LCD_E 0x80
#define LCD_RW 0x40
#define LCD_RS 0x20

static FILE *iolog = NULL;

static uint8_t data = 0;

static uint8_t ddra = 0;
static uint8_t ddrb = 0;

// Status Register
// 0x80 = execute
// 0x40 = read(1)/write(0)
// 0x20 = register select (0 = instruction, 1 = data)
static uint8_t status = 0;

uint8_t bits;

uint8_t lines;

#define FONT5_10 1
#define FONT5_8  2
uint8_t font;

char LCD[2][16];
uint8_t line = 0;
uint8_t cursor = 0;

void mmio_init()
{
    iolog = fopen("mmio.log", "w");
}

void mmio_led_lights(uint16_t address, uint8_t value)
{
    char bits[9];
    switch (address)
    {
    case LCD_PORTB:
        for (int i = 7; i >= 0; i--)
        {
            if (value & 1 << i)
                bits[i] = '*';
            else
                bits[i] = ' ';
        }
        bits[8] = '\0';
        printf("\r%s", bits);
        break;
    }
}

void mmio_read_data()
{
    printf("Read data: %x\n", data);
}

void mmio_write_data()
{
    LCD[0][cursor] = data;
    cursor++;
    LCD[0][cursor] = '\0';
    printf("\r%s", LCD[0]);
}

void mmio_read_instruction()
{
    printf("Read instruction: %x\n", data);
}
void mmio_set_ddram_address()
{
    printf("set ddram address\n");
}
void mmio_set_cgram_address()
{
    printf("set cgram address\n");
}
void mmio_function_set()
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
}
void mmio_shift()
{
    printf("mmio shift\n");
}
void mmio_display_ctl()
{
}
void mmio_mode_set()
{
}
void mmio_return_home()
{
    printf("return home\n");
}
void mmio_clear()
{
    printf("clear\n");
}

void mmio_write_instruction()
{
    if (data & 0x80)
        mmio_set_ddram_address();
    else if (data & 0x40)
        mmio_set_cgram_address();
    else if (data & 0x20)
        mmio_function_set();
    else if (data & 0x10)
        mmio_shift();
    else if (data & 0x08)
        mmio_display_ctl();
    else if (data & 0x04)
        mmio_mode_set();
    else if (data & 0x02)
        mmio_return_home();
    else if (data & 0x01)
        mmio_clear();
    else
        fprintf(stderr, "mmio no op %d\n", data);
}

void mmio_rw()
{
    if (status & LCD_RW)
    {
        if (status & LCD_RS)
            mmio_read_data();
        else
            mmio_read_instruction();
    }
    else
    {
        if (status & LCD_RS)
            mmio_write_data();
        else
            mmio_write_instruction();
    }
}

void mmio_lcd_status(uint8_t value)
{
    status = value;
    if (status & LCD_E)
    {
        mmio_rw();
    }
}

void mmio_lcd_display(uint16_t address, uint8_t value)
{
    switch (address)
    {
    case LCD_PORTA:
        fprintf(iolog, "LCD_PORTA: %x\n", value);
        mmio_lcd_status(value);
        break;
    case LCD_PORTB:
        fprintf(iolog, "LCD_PORTB: %x\n", value);
        data = value;
        break;
    case LCD_DDRA:
        fprintf(iolog, "LCD_DDRA: %x\n", value);
        ddra = value;
        break;
    case LCD_DDRB:
        fprintf(iolog, "LCD_DDRB: %x\n", value);
        ddrb = value;
        break;
    }
}

void mmio_write(uint16_t address, uint8_t value)
{
    if (address >= 0xB000 && address <= 0xBFFF)
    {
        if (LED_LIGHTS)
            mmio_led_lights(address, value);
        if (LCD_DISPLAY)
            mmio_lcd_display(address, value);
    }
}