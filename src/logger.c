#include "logger.h"

FILE* logfile= NULL;

void logger_init(int verbose) {
    if (verbose) {
        logfile = fopen("emulator.log","a");
        //setvbuf(logfile, NULL, _IONBF, 0); 
        fprintf(logfile,"LOGGING...\n");
    }
}

void logger_close() {
    fclose(logfile);
}