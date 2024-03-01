
extern void ram_init(char* filename);
extern void ram_fill(uint8_t size, uint16_t reset_vector);
extern uint8_t read6502(uint16_t address);
extern void write6502(uint16_t address, uint8_t value);
