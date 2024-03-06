#pragma once

extern void reset6502();
 /*   - Call this once before you begin execution.    */
 
 extern void exec6502(uint32_t tickcount) ;
 /*   - Execute 6502 code up to the next specified    *
  *     count of clock ticks.                         */
 
  extern void step6502()                  ;
 /*   - Execute a single instrution.                  *
  *                                                   */
  extern void irq6502()                  ;
 /*   - Trigger a hardware IRQ in the 6502 core.      *
 *                                                   */
  extern void nmi6502()                 ;
 /*   - Trigger an NMI in the 6502 core.              *
 *                                                   */
  extern void hookexternal(void *funcptr);
 /*   - Pass a pointer to a void function taking no   *
 *     parameters. This will cause Fake6502 to call  *
 *     that function once after each emulated        *
 *     instruction.  */