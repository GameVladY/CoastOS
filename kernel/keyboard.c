/* =============================================================
 * CoastOS - PS/2 Keyboard Driver
 * kernel/keyboard.c
 * ============================================================= */
#include "keyboard.h"

#define KB_DATA   0x60
#define KB_STATUS 0x64

static inline uint8_t inb(uint16_t port) {
    uint8_t v;
    asm volatile("inb %1, %0" : "=a"(v) : "Nd"(port));
    return v;
}

static const uint8_t scancode_map[128] = {
    0,   27,  '1', '2', '3', '4', '5', '6', '7', '8',
    '9', '0', '-', '=', '\b','\t','q', 'w', 'e', 'r',
    't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',0,
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';',
    '\'','`', 0,   '\\','z','x', 'c', 'v', 'b', 'n',
    'm', ',', '.', '/', 0,   '*', 0,   ' ',
};

void keyboard_init(void) {
    /* Flush any pending data */
    while (inb(KB_STATUS) & 0x01) inb(KB_DATA);
}

uint8_t keyboard_poll(void) {
    if (!(inb(KB_STATUS) & 0x01)) return 0;
    uint8_t sc = inb(KB_DATA);
    if (sc & 0x80) return 0;      /* key release */
    if (sc < 128)  return scancode_map[sc];
    return 0;
}
