#pragma once

extern void window_init();
extern void window_lcd_clear();
extern void window_lcd_home();
extern void window_lcd_putc(char ch);
extern void window_serial_putc(char ch);
extern void window_show_state();
extern void window_shutdown();
extern void window_mem_forward();
extern void window_mem_backward();
extern void window_resize();
