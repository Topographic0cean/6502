
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

extern Options* process_options(int argc, const char **argv);
