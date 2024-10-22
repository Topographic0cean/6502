
#include <stdarg.h>

#include "logger.h"

FILE* logfile= NULL;

static int logger_level;

void logger_init(int verbose) {
    logger_level = verbose;
    if (logger_level) {
        logfile = fopen("emulator.log","a");
        fprintf(logfile,"LOGGING...\n");
        fflush(logfile);
    }
}

void logger_log(int level, char* fmt, ...) {
    va_list valist;

    if (level > 0 && level <= logger_level) {
        va_start(valist,fmt);
        vfprintf(logfile, fmt, valist);
        fflush(logfile);
        va_end(valist);
    }
}

void logger_close() {
    fclose(logfile);
}