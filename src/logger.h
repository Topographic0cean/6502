#pragma once

#include <stdio.h>

extern FILE* logfile;
void logger_init(int log);
void logger_close();

#define log(...) fprintf(logfile, __VA_ARGS__)
