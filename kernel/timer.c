/* CoastOS - PIT Timer Implementation */
#include "timer.h"

#define PIT_CMD   0x43
#define PIT_CH0   0x40
#define PIC1_CMD  0x20
#define PIC1_DATA 0x21
#define PIC_EOI   0x20

static inline void outb(uint16_t port, uint8_t val) {
    asm volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}
static inline uint8_t inb(uint16_t port) {
    uint8_t v; asm volatile("inb %1, %0" : "=a"(v) : "Nd"(port)); return v;
}

/* Minimal IDT entry */
struct idt_entry { uint16_t off_lo, sel; uint8_t zero, flags; uint16_t off_hi; } __attribute__((packed));
struct idt_ptr   { uint16_t limit; uint32_t base; } __attribute__((packed));

static struct idt_entry idt[256];
static struct idt_ptr   idtp;

static void idt_set(uint8_t n, uint32_t handler) {
    idt[n].off_lo = handler & 0xFFFF;
    idt[n].sel    = 0x08;
    idt[n].zero   = 0;
    idt[n].flags  = 0x8E;
    idt[n].off_hi = (handler >> 16) & 0xFFFF;
}

static void timer_irq(void) {
    g_ticks++;
    outb(PIC1_CMD, PIC_EOI);
}

/* Naked ISR trampoline */
static void __attribute__((naked)) timer_isr(void) {
    asm volatile(
        "pusha\n"
        "call timer_irq\n"
        "popa\n"
        "iret\n"
    );
}

void timer_init(uint32_t hz) {
    g_ticks = 0;

    /* Remap PIC: IRQ0-7 -> INT 0x20-0x27 */
    outb(0x20, 0x11); outb(0xA0, 0x11);
    outb(0x21, 0x20); outb(0xA1, 0x28);
    outb(0x21, 0x04); outb(0xA1, 0x02);
    outb(0x21, 0x01); outb(0xA1, 0x01);
    outb(0x21, 0x00); outb(0xA1, 0xFF); /* enable only IRQ0 */

    /* PIT channel 0, rate generator */
    uint32_t divisor = 1193180 / hz;
    outb(PIT_CMD, 0x36);
    outb(PIT_CH0, divisor & 0xFF);
    outb(PIT_CH0, (divisor >> 8) & 0xFF);

    /* IDT */
    idtp.limit = sizeof(idt) - 1;
    idtp.base  = (uint32_t)idt;
    idt_set(0x20, (uint32_t)timer_isr);
    asm volatile("lidt [%0]" : : "r"(&idtp));
    asm volatile("sti");
}

void timer_sleep(uint32_t ticks) {
    uint32_t end = g_ticks + ticks;
    while (g_ticks < end) asm volatile("hlt");
}
