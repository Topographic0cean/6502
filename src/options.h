#pragma once

typedef struct options
{
    int paused;
    char *rom;
    char *load;
    int clocks;
    int sleep;
    int verbose;
    int core;
} Options;

extern Options* process_options(int argc, const char **argv);
