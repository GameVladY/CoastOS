/* =============================================================
 * CoastOS - PIT Timer Driver
 * kernel/timer.h + timer.c (combined for simplicity)
 * ============================================================= */
#ifndef TIMER_H
#define TIMER_H
#include <stdint.h>

volatile uint32_t g_ticks;   /* incremented each IRQ0 */

void timer_init(uint32_t hz);
void timer_sleep(uint32_t ticks);

#endif
