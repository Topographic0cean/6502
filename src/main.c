#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <popt.h>
#include <ncurses.h>

#include "6502.h"
#include "ram.h"
#include "w65c22.h"
#include "uart.h"
#include "display.h"

typedef struct options
{
    char *rom;
    int clocks;
    int sleep;
    int instructions;
    int io;
    int core;
    int verbose;
} Options;

struct poptOption optionsTable[] = {
    {"rom", 'r', POPT_ARG_STRING, 0, 'r', "ROM file to load", "file"},
    {"clocks", 'c', POPT_ARG_INT, 0, 'c', "Number of clocks to run", "clocks"},
    {"sleep", 's', POPT_ARG_INT, 0, 's', "Sleep time between clocks", "nanoseconds"},
    {"instructions", 'i', POPT_ARG_NONE, 0, 'i', "Print instructions", NULL},
    {"io", 'o', POPT_ARG_NONE, 0, 'o', "Print IO", NULL},
    {"core", 'e', POPT_ARG_NONE, 0, 'e', "Dump core at end.", NULL},
    {"verbose", 'v', POPT_ARG_NONE, 0, 'v', "Verbose", NULL},
    POPT_AUTOHELP{NULL, 0, 0, NULL, 0}};

static int nmi = 0;
static int irq = 0;
static int done = 0;

void process_options(int argc, const char **argv, Options *options)
{
    int c;

    options->rom = "rom.bin";
    options->clocks = 0;
    options->sleep = 1;
    options->instructions = 0;
    options->io = 0;
    options->core = 0;
    options->verbose = 0;

    poptContext optCon = poptGetContext(NULL, argc, argv, optionsTable, 0);
    while ((c = poptGetNextOpt(optCon)) >= 0)
    {
        switch (c)
        {
        case 'r':
            options->rom = poptGetOptArg(optCon);
            break;
        case 'c':
            options->clocks = atoi(poptGetOptArg(optCon));
            break;
        case 's':
            options->sleep = atoi(poptGetOptArg(optCon));
            break;
        case 'i':
            options->instructions = 1;
            break;
        case 'o':
            options->io = 1;
            break;
        case 'e':
            options->core = 1;
            break;
        case 'v':
            options->verbose = 1;
            break;
        }
    }
    poptFreeContext(optCon);
}

void nmi_interrupt(int signum)
{
    nmi = 1;
}

void maskable_interrupt(int signum)
{
    irq = 1;
}

void quit(int signum)
{
    printf("QUIT\n");
    done = 1;
    endwin();
}

void setup_interrupt_handlers()
{
    signal(SIGUSR2, nmi_interrupt);
    signal(SIGINT, quit);
    signal(SIGQUIT, quit);
    signal(SIGUSR1, maskable_interrupt);
    signal(SIGABRT, dump_core);
}

void initialize( Options* options)
{
    setup_interrupt_handlers();
    initscr();
    cbreak();
    noecho();   
    ram_init(options->rom, options->instructions);
    w65c22_init(options->verbose);
    uart_init(options->verbose);
    display_init(options->io);
    reset6502();
}

int main(int argc, const char *argv[])
{
    struct timespec asleep;
    Options options;

    process_options(argc, argv, &options);

    asleep.tv_sec = 0;
    asleep.tv_nsec = options.sleep;
    if (options.sleep == 0)
    {
        asleep.tv_nsec = 1;
    }

    initialize(&options);

    int c = 0;
    while (options.clocks == 0 || c < options.clocks)
    {
        if (nmi == 1)
        {
            nmi6502();
            nmi = 0;
        }
        if (irq == 1)
        {
            irq6502();
            irq = 0;
        }
        if (done == 1)
        {
            break;
        }
        step6502();
        w65c22_tick();
        if (options.sleep > 0)
            nanosleep(&asleep, NULL);
        c++;
    }
    if (options.core == 1)
        dump_core();

    exit(0);
}
