#include <stdlib.h>
#include <popt.h>

#include "options.h"

static Options options;

struct poptOption optionsTable[] = {
    {"clocks", 'c', POPT_ARG_INT, 0, 'c', "Number of clocks to run", "clocks"},
    {"core", 'e', POPT_ARG_NONE, 0, 'e', "Dump core at end.", NULL},
    {"load", 'l', POPT_ARG_STRING, 0, 'l', "Load prog file", NULL},
    {"paused", 'p', POPT_ARG_NONE, 0, 'p', "Paused at start", NULL},
    {"rom", 'r', POPT_ARG_STRING, 0, 'r', "ROM file to load", "file"},
    {"sleep", 's', POPT_ARG_INT, 0, 's', "Sleep time between clocks", "nanoseconds"},
    {"verbose", 'v', POPT_ARG_INT, 0, 'v', "Verbose", "level"},
    POPT_AUTOHELP{NULL, 0, 0, NULL, 0}};

Options* process_options(int argc, const char **argv)
{
    int c;

    options.load = "";
    options.paused = 0;
    options.rom = "rom/rom.bin";
    options.clocks = 0;
    options.sleep = 0;
    options.verbose = 0;
    options.core = 0;

    poptContext optCon = poptGetContext(NULL, argc, argv, optionsTable, 0);
    while ((c = poptGetNextOpt(optCon)) >= 0)
    {
        switch (c)
        {
        case 'l':
            options.load = poptGetOptArg(optCon);
            break;
        case 'p':
            options.paused = 1;
            break;
        case 'r':
            options.rom = poptGetOptArg(optCon);
            break;
        case 'c':
            options.clocks = atoi(poptGetOptArg(optCon));
            break;
        case 's':
            options.sleep = atoi(poptGetOptArg(optCon));
            break;
        case 'v':
            options.verbose = atoi(poptGetOptArg(optCon));
            break;
        case 'e':
            options.core = 1;
            break;
        }
    }
    poptFreeContext(optCon);
    return &options;
}
