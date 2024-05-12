#include <ncurses.h>

#include "window.h"


static int window_rows;
static int window_cols;

static WINDOW* memory;
static WINDOW* lcd;
static WINDOW* registers;
static WINDOW* serial;

void window_init() {
    int rows, cols;

    initscr();
    getmaxyx( stdscr, window_rows, window_cols);

    memory = newwin(window_rows/2,window_cols/2,0,0);
    lcd = newwin(4,window_cols/2,0,window_cols/2);
    registers = newwin(window_rows/2 - 4,window_cols/2,4,window_cols/2);
    serial = newwin(window_rows/2,window_cols,window_rows/2,0);
    refresh();

    box(memory,0,0);
    box(lcd,0,0);
    box(registers,0,0);

    scrollok(serial, 1);

    mvwprintw(memory, 1,1,"Memory");
    wrefresh(memory);
    mvwprintw(registers, 1,1,"registers");
    wrefresh(registers);
}

void window_lcd_clear() {
    wclear(lcd);
    box(lcd,0,0);
    wmove(lcd, 1, 1);
    wrefresh(lcd);
}

void window_lcd_home() {
    wmove(lcd, 1, 1);
}

void window_lcd_putc(char ch) {
    wechochar(lcd,ch);
}

void window_serial_putc(char ch){
    if (ch != '\r')
        wechochar(serial,ch);
}

void window_shutdown() {
    endwin();
}
