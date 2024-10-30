#pragma once

#include <stdio.h>

#define LOGGER_IO   1
#define LOGGER_CODE 2

extern FILE* logfile;
extern void logger_init(int log);
extern void logger_log(int level, char* fmt, ...);
extern void logger_close();
