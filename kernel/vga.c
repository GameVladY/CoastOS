/* =============================================================
 * CoastOS - VGA Text Mode Driver Implementation
 * kernel/vga.c
 * ============================================================= */
#include "vga.h"

/* Box-drawing characters (CP437) */
#define BOX_TL  0xDA   /* ┌ */
#define BOX_TR  0xBF   /* ┐ */
#define BOX_BL  0xC0   /* └ */
#define BOX_BR  0xD9   /* ┘ */
#define BOX_H   0xC4   /* ─ */
#define BOX_V   0xB3   /* │ */
#define BOX_T   0xC2   /* ┬ */
#define BOX_B   0xC1   /* ┴ */
#define BOX_L   0xC3   /* ├ */
#define BOX_R   0xB4   /* ┤ */
#define BOX_X   0xC5   /* ┼ */

/* Double-line box */
#define DBOX_TL 0xC9   /* ╔ */
#define DBOX_TR 0xBB   /* ╗ */
#define DBOX_BL 0xC8   /* ╚ */
#define DBOX_BR 0xBC   /* ╝ */
#define DBOX_H  0xCD   /* ═ */
#define DBOX_V  0xBA   /* ║ */

static int    cursor_x   = 0;
static int    cursor_y   = 0;
static uint8_t current_attr;

/* I/O port helpers */
static inline void outb(uint16_t port, uint8_t val) {
    asm volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}

void vga_init(void) {
    current_attr = vga_attr(VGA_LIGHT_GREY, VGA_BLACK);
    vga_clear(VGA_BLACK);
    vga_hide_cursor();
}

void vga_clear(vga_color_t bg) {
    uint8_t attr = vga_attr(VGA_LIGHT_GREY, bg);
    for (int y = 0; y < VGA_HEIGHT; y++)
        for (int x = 0; x < VGA_WIDTH; x++)
            VGA_BUFFER[y * VGA_WIDTH + x] = vga_entry(' ', attr);
    cursor_x = 0;
    cursor_y = 0;
}

void vga_set_color(vga_color_t fg, vga_color_t bg) {
    current_attr = vga_attr(fg, bg);
}

void vga_putchar(char c) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
    } else if (c == '\r') {
        cursor_x = 0;
    } else if (c == '\b') {
        if (cursor_x > 0) cursor_x--;
    } else {
        VGA_BUFFER[cursor_y * VGA_WIDTH + cursor_x] = vga_entry(c, current_attr);
        cursor_x++;
    }
    if (cursor_x >= VGA_WIDTH) { cursor_x = 0; cursor_y++; }
    if (cursor_y >= VGA_HEIGHT) vga_scroll();
}

void vga_puts(const char *s) {
    while (*s) vga_putchar(*s++);
}

void vga_putchar_at(int x, int y, char c) {
    if (x < 0 || x >= VGA_WIDTH || y < 0 || y >= VGA_HEIGHT) return;
    VGA_BUFFER[y * VGA_WIDTH + x] = vga_entry(c, current_attr);
}

void vga_puts_at(int x, int y, const char *s) {
    int ox = x;
    while (*s) {
        if (*s == '\n') { y++; x = ox; s++; continue; }
        vga_putchar_at(x++, y, *s++);
    }
}

void vga_put_attr_at(int x, int y, char c, uint8_t attr) {
    if (x < 0 || x >= VGA_WIDTH || y < 0 || y >= VGA_HEIGHT) return;
    VGA_BUFFER[y * VGA_WIDTH + x] = vga_entry(c, attr);
}

void vga_draw_hline(int x, int y, int len, char c, uint8_t attr) {
    for (int i = 0; i < len; i++)
        vga_put_attr_at(x + i, y, c, attr);
}

void vga_draw_vline(int x, int y, int len, char c, uint8_t attr) {
    for (int i = 0; i < len; i++)
        vga_put_attr_at(x, y + i, c, attr);
}

void vga_fill_rect(int x, int y, int w, int h, char c, uint8_t attr) {
    for (int row = 0; row < h; row++)
        for (int col = 0; col < w; col++)
            vga_put_attr_at(x + col, y + row, c, attr);
}

/* Draw a single-line box */
void vga_draw_box(int x, int y, int w, int h, uint8_t attr) {
    /* Corners */
    vga_put_attr_at(x,         y,         BOX_TL, attr);
    vga_put_attr_at(x + w - 1, y,         BOX_TR, attr);
    vga_put_attr_at(x,         y + h - 1, BOX_BL, attr);
    vga_put_attr_at(x + w - 1, y + h - 1, BOX_BR, attr);
    /* Edges */
    vga_draw_hline(x + 1, y,         w - 2, BOX_H, attr);
    vga_draw_hline(x + 1, y + h - 1, w - 2, BOX_H, attr);
    vga_draw_vline(x,         y + 1, h - 2, BOX_V, attr);
    vga_draw_vline(x + w - 1, y + 1, h - 2, BOX_V, attr);
}

void vga_scroll(void) {
    for (int y = 0; y < VGA_HEIGHT - 1; y++)
        for (int x = 0; x < VGA_WIDTH; x++)
            VGA_BUFFER[y * VGA_WIDTH + x] = VGA_BUFFER[(y + 1) * VGA_WIDTH + x];
    uint8_t attr = vga_attr(VGA_LIGHT_GREY, VGA_BLACK);
    for (int x = 0; x < VGA_WIDTH; x++)
        VGA_BUFFER[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vga_entry(' ', attr);
    cursor_y = VGA_HEIGHT - 1;
}

void vga_set_cursor(int x, int y) {
    uint16_t pos = (uint16_t)(y * VGA_WIDTH + x);
    outb(0x3D4, 0x0F); outb(0x3D5, (uint8_t)(pos & 0xFF));
    outb(0x3D4, 0x0E); outb(0x3D5, (uint8_t)((pos >> 8) & 0xFF));
}

void vga_hide_cursor(void) {
    outb(0x3D4, 0x0A);
    outb(0x3D5, 0x20);
}
