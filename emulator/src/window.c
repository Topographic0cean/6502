#include <ncurses.h>
#include <stdint.h>

#include "window.h"
#include "ram.h"
#include "6502.h"

static int window_rows;
static int window_cols;

static int memory_address = 0;

static WINDOW* memory;
static WINDOW* lcd;
static WINDOW* registers;
static WINDOW* serial;

void window_init() {
    int rows, cols;

    initscr();

    noecho();
    raw();
    timeout(0);

    getmaxyx(stdscr, window_rows, window_cols);

    memory = newwin(window_rows/2,window_cols/2,0,0);
    lcd = newwin(4,window_cols/2,0,window_cols/2);
    registers = newwin(window_rows/2 - 4,window_cols/2,4,window_cols/2);
    serial = newwin(window_rows/2,window_cols,window_rows/2,0);
    scrollok(serial, 1);

    box(memory,0,0);
    box(lcd,0,0);
    box(registers,0,0);

    refresh();

    wrefresh(memory);
    wrefresh(lcd);
    wrefresh(registers);
}

void windows_status(char* status) {
    wprintw(serial,"%s",status);
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
    char label[64];
    int r, c;
    getmaxyx( registers, r, c);

    int pos = 1;
    int pc_start = pc;

    mvwprintw(registers, pos++,1, "A    %02X",a );
    mvwprintw(registers, pos++,1, "X    %02X",x );
    mvwprintw(registers, pos++,1, "Y    %02X",y );
    mvwprintw(registers, pos++,1, "STAT %02X",status );
    mvwprintw(registers, pos++,1, "PC   %04X",pc );
    mvwprintw(registers, pos++,1, "SP   %02X",sp );
    pos = 1;
    while (pos < r - 2) {
        int adv = string6502(label, pc_start);
        mvwprintw(registers, pos++, 11, "%04X: %s", pc_start, label);
        pc_start += adv;
    }
    wrefresh(registers);

    getmaxyx( memory, r, c);

    uint16_t memaddr = memory_address;
    for (int row = 1; row < r-2; row++) {
        mvwprintw(memory, row, 1, "%04X: ", memaddr);
        for (int col = 0; col < 8; col++) {
            mvwprintw(memory, row, 7+col*3, "%02X ", ram_read(memaddr++));
        }
    }
    wrefresh(memory);
}

void window_mem_forward() {
    memory_address += 0x32;
    if (memory_address > 0xFFFF)
        memory_address -= 0x32;
}

void window_mem_backward() {
    memory_address -= 0x32;
    if (memory_address < 0)
        memory_address = 0;
}

void window_resize() {
    int rows, cols;

    clear();
    refresh();
    getmaxyx( stdscr, rows, cols);
    wclear(memory);
    wclear(lcd);
    wclear(registers);
    wresize(memory,rows/2,cols/2);
    wresize(lcd, 4,cols/2);
    wresize(registers,rows/2 - 4,cols/2);
    wresize(serial,rows/2,cols);
    mvwin(lcd,0,cols/2);
    mvwin(registers,4,cols/2);
    mvwin(serial,rows/2,0);
    mvwprintw(memory,2,2,"%d,%d",rows,cols);
    mvwprintw(memory,3,2,"%d,%d",rows/2,cols/2);
    mvwprintw(registers,3,2,"%d,%d",rows/2,cols/2);
    box(memory,0,0);
    box(lcd,0,0);
    box(registers,0,0);
    wrefresh(memory);
    wrefresh(lcd);
    wrefresh(registers);
    wrefresh(serial);
}
