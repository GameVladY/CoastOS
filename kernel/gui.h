/* =============================================================
 * CoastOS - GUI Shell Header
 * kernel/gui.h
 * ============================================================= */
#ifndef GUI_H
#define GUI_H

#include <stdint.h>
#include "vga.h"

/* ── Colour palette for CoastOS GUI ── */
#define GUI_DESKTOP_BG    VGA_CYAN
#define GUI_TASKBAR_BG    VGA_BLUE
#define GUI_WINDOW_BG     VGA_LIGHT_GREY
#define GUI_TITLE_BG      VGA_BLUE
#define GUI_TITLE_FG      VGA_WHITE
#define GUI_BTN_BG        VGA_LIGHT_GREY
#define GUI_BTN_FG        VGA_BLACK
#define GUI_BTN_SHADOW    VGA_DARK_GREY
#define GUI_BORDER        VGA_DARK_GREY
#define GUI_TEXT_FG       VGA_BLACK
#define GUI_STATUS_FG     VGA_YELLOW
#define GUI_HIGHLIGHT_BG  VGA_BLUE
#define GUI_HIGHLIGHT_FG  VGA_WHITE
#define GUI_ICON_FG       VGA_WHITE

/* ── Window descriptor ── */
#define MAX_WINDOWS  8

typedef struct {
    int      x, y, w, h;
    char     title[32];
    int      active;
    int      visible;
    void   (*draw_content)(int x, int y, int w, int h);
} Window;

/* ── Button descriptor ── */
typedef struct {
    int   x, y, w;
    char  label[20];
    void (*on_click)(void);
} Button;

/* Public GUI API */
void gui_init(void);
void gui_run(void);
void gui_draw_desktop(void);
void gui_draw_taskbar(void);
void gui_draw_window(Window *win);
void gui_draw_button(int x, int y, int w, const char *label, int pressed);
void gui_draw_icon(int x, int y, const char *icon, const char *label);
void gui_open_window(int idx);
void gui_close_window(int idx);

/* Built-in app windows */
void draw_about_content(int x, int y, int w, int h);
void draw_terminal_content(int x, int y, int w, int h);
void draw_info_content(int x, int y, int w, int h);
void draw_colours_content(int x, int y, int w, int h);

/* Boot splash (defined in kernel.c) */
void boot_splash(void);

#endif /* GUI_H */
