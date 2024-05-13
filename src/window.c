#include <ncurses.h>

#include "window.h"
#include "ram.h"


static int window_rows;
static int window_cols;

static WINDOW* memory;
static WINDOW* lcd;
static WINDOW* registers;
static WINDOW* serial;

void window_init() {
    int rows, cols;

    initscr();

    noecho();
    cbreak();
    timeout(0);
    
    getmaxyx( stdscr, window_rows, window_cols);

    memory = newwin(window_rows/2,window_cols/2,0,0);
    lcd = newwin(4,window_cols/2,0,window_cols/2);
    registers = newwin(window_rows/2 - 4,window_cols/2,4,window_cols/2);
    serial = newwin(window_rows/2,window_cols,window_rows/2,0);

    box(memory,0,0);
    box(lcd,0,0);
    box(registers,0,0);

    refresh();

    scrollok(serial, 1);

    wrefresh(memory);
    wrefresh(lcd);
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

extern uint16_t pc;
extern uint8_t sp, a, x, y, status;
void window_show_state() {
    int pos = 1;
    int pc_start = pc - 7;
    int pc_end = pc + 8;
    if (pc_start < 0) pc_start = 0;
    if (pc_end > 0xFFFF) pc_start = 0xFFFF;

    mvwprintw(registers, pos++,1, "A    %02X",a );
    mvwprintw(registers, pos++,1, "X    %02X",x );
    mvwprintw(registers, pos++,1, "Y    %02X",y );
    mvwprintw(registers, pos++,1, "STAT %02X",status );
    mvwprintw(registers, pos++,1, "PC   %04X",pc );
    pos++;

    for (int i = pc_start; i <= pc_end; i++) {
        mvwprintw(registers, pos++, 1, "%04X: %02X", i, ram_read(i));
    }
    wrefresh(registers);
}
