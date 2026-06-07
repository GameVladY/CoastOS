/* =============================================================
 * CoastOS - VGA Text Mode Driver
 * kernel/vga.h
 * ============================================================= */
#ifndef VGA_H
#define VGA_H

#include "types.h"


/* VGA text buffer address */
#define VGA_BUFFER   ((volatile uint16_t*)0xB8000)
#define VGA_WIDTH    80
#define VGA_HEIGHT   25

/* VGA colour indices */
typedef enum {
    VGA_BLACK        = 0,
    VGA_BLUE         = 1,
    VGA_GREEN        = 2,
    VGA_CYAN         = 3,
    VGA_RED          = 4,
    VGA_MAGENTA      = 5,
    VGA_BROWN        = 6,
    VGA_LIGHT_GREY   = 7,
    VGA_DARK_GREY    = 8,
    VGA_LIGHT_BLUE   = 9,
    VGA_LIGHT_GREEN  = 10,
    VGA_LIGHT_CYAN   = 11,
    VGA_LIGHT_RED    = 12,
    VGA_LIGHT_MAGENTA= 13,
    VGA_YELLOW       = 14,
    VGA_WHITE        = 15,
} vga_color_t;

/* Pack fg + bg into attribute byte */
static inline uint8_t vga_attr(vga_color_t fg, vga_color_t bg) {
    return (uint8_t)((bg << 4) | fg);
}

/* Pack character + attribute into VGA word */
static inline uint16_t vga_entry(char c, uint8_t attr) {
    return (uint16_t)((uint16_t)attr << 8 | (uint8_t)c);
}

/* Public API */
void     vga_init(void);
void     vga_clear(vga_color_t bg);
void     vga_set_color(vga_color_t fg, vga_color_t bg);
void     vga_putchar(char c);
void     vga_puts(const char *s);
void     vga_putchar_at(int x, int y, char c);
void     vga_puts_at(int x, int y, const char *s);
void     vga_put_attr_at(int x, int y, char c, uint8_t attr);
void     vga_draw_hline(int x, int y, int len, char c, uint8_t attr);
void     vga_draw_vline(int x, int y, int len, char c, uint8_t attr);
void     vga_draw_box(int x, int y, int w, int h, uint8_t attr);
void     vga_fill_rect(int x, int y, int w, int h, char c, uint8_t attr);
void     vga_scroll(void);
void     vga_set_cursor(int x, int y);
void     vga_hide_cursor(void);

#endif /* VGA_H */
