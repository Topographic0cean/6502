#include "logger.h"

FILE* logfile= NULL;

void logger_init(int log) {
    if (log) {
        logfile = fopen("emulator.log","wa");
    }
}

void logger_close() {
    fclose(logfile);
}