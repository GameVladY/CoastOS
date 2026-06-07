/* =============================================================
 * CoastOS - PIT Timer Driver
 * kernel/timer.h + timer.c (combined for simplicity)
 * ============================================================= */
#ifndef TIMER_H
#define TIMER_H
#include "types.h"

extern volatile uint32_t g_ticks;  /* defined in timer.c */

void timer_init(uint32_t hz);
void timer_sleep(uint32_t ticks);

#endif
