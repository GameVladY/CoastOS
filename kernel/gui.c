/* =============================================================
 * CoastOS - GUI Shell Implementation
 * kernel/gui.c
 *
 * Renders a complete 32-bit text-mode GUI:
 *   • Cyan desktop with icons
 *   • Blue taskbar with clock area
 *   • Draggable/switchable windows with title bars
 *   • 3-D style buttons (shadow trick in CP437)
 *   • Keyboard-driven menus
 * ============================================================= */
#include "gui.h"
#include "vga.h"
#include "keyboard.h"
#include "timer.h"

/* ── Tick counter (incremented by timer ISR) ── */
extern volatile uint32_t g_ticks;

/* ── Window registry ── */
static Window windows[MAX_WINDOWS];
static int    active_win = -1;
static int    win_count  = 0;

/* ── Helpers ── */
static void str_copy(char *dst, const char *src, int max) {
    int i = 0;
    while (src[i] && i < max - 1) { dst[i] = src[i]; i++; }
    dst[i] = 0;
}

static int str_len(const char *s) {
    int n = 0; while (s[n]) n++; return n;
}

static void uint_to_dec(uint32_t v, char *buf, int width) {
    char tmp[12]; int i = 0;
    if (v == 0) { tmp[i++] = '0'; }
    while (v) { tmp[i++] = '0' + (v % 10); v /= 10; }
    /* pad */
    int pad = width - i;
    int j = 0;
    while (pad-- > 0) buf[j++] = '0';
    while (i-- > 0) buf[j++] = tmp[i];
    buf[j] = 0;
}

/* ============================================================
 * BUTTON  -  raised 3-D look using background colour shifts
 * ============================================================ */
void gui_draw_button(int x, int y, int w, const char *label, int pressed) {
    uint8_t btn_attr  = vga_attr(GUI_BTN_FG, GUI_BTN_BG);
    uint8_t shd_attr  = vga_attr(GUI_BTN_SHADOW, GUI_BTN_BG);

    /* Button body */
    vga_fill_rect(x, y, w, 1, ' ', btn_attr);
    int llen = str_len(label);
    int lx   = x + (w - llen) / 2;
    uint8_t save_attr; (void)save_attr;
    /* draw label */
    for (int i = 0; i < llen; i++)
        vga_put_attr_at(lx + i, y, label[i], btn_attr);

    if (!pressed) {
        /* Top-left highlight (light edge) */
        vga_put_attr_at(x - 1, y, ' ', vga_attr(GUI_BTN_BG, VGA_WHITE));
        /* Bottom-right shadow */
        vga_put_attr_at(x + w, y, ' ', shd_attr);
    } else {
        /* Pressed: invert highlight/shadow */
        vga_put_attr_at(x - 1, y, ' ', shd_attr);
        vga_put_attr_at(x + w, y, ' ', vga_attr(GUI_BTN_BG, VGA_WHITE));
    }
}

/* ============================================================
 * ICON  -  desktop icon with glyph + label below
 * ============================================================ */
void gui_draw_icon(int x, int y, const char *icon, const char *label) {
    uint8_t icon_attr  = vga_attr(GUI_ICON_FG,  GUI_DESKTOP_BG);
    uint8_t label_attr = vga_attr(VGA_WHITE,     GUI_DESKTOP_BG);

    /* 3-char wide icon box */
    vga_put_attr_at(x,     y, '[', icon_attr);
    vga_put_attr_at(x + 1, y, icon[0], icon_attr);
    vga_put_attr_at(x + 2, y, ']', icon_attr);
    /* Label */
    int llen = str_len(label);
    int lx   = x - (llen - 3) / 2;
    for (int i = 0; i < llen; i++)
        vga_put_attr_at(lx + i, y + 1, label[i], label_attr);
}

/* ============================================================
 * DESKTOP
 * ============================================================ */
void gui_draw_desktop(void) {
    /* Flood-fill desktop cyan */
    vga_fill_rect(0, 0, VGA_WIDTH, VGA_HEIGHT - 1, ' ',
                  vga_attr(VGA_WHITE, GUI_DESKTOP_BG));

    /* Subtle pattern lines every 5 rows */
    for (int y = 0; y < VGA_HEIGHT - 1; y += 5) {
        vga_draw_hline(0, y, VGA_WIDTH, 0xB0,
                       vga_attr(VGA_CYAN, GUI_DESKTOP_BG));
    }

    /* Title area at top */
    vga_fill_rect(0, 0, VGA_WIDTH, 1, ' ',
                  vga_attr(VGA_WHITE, VGA_BLUE));
    uint8_t title_attr = vga_attr(VGA_YELLOW, VGA_BLUE);
    const char *os_title = " CoastOS v1.0  |  32-bit Text GUI";
    for (int i = 0; os_title[i]; i++)
        vga_put_attr_at(i, 0, os_title[i], title_attr);

    /* Clock placeholder right-aligned */
    uint8_t clk_attr = vga_attr(VGA_WHITE, VGA_BLUE);
    const char *clk = "00:00:00 ";
    int clkx = VGA_WIDTH - str_len(clk);
    for (int i = 0; clk[i]; i++)
        vga_put_attr_at(clkx + i, 0, clk[i], clk_attr);

    /* Desktop icons */
    gui_draw_icon(4,  3, "*", "About");
    gui_draw_icon(4,  7, ">", "Terminal");
    gui_draw_icon(4, 11, "i", "System");
    gui_draw_icon(4, 15, "#", "Colours");
    gui_draw_icon(4, 19, "X", "Quit");
}

/* ============================================================
 * TASKBAR  (bottom row)
 * ============================================================ */
void gui_draw_taskbar(void) {
    uint8_t tb_attr = vga_attr(VGA_WHITE, GUI_TASKBAR_BG);
    vga_fill_rect(0, VGA_HEIGHT - 1, VGA_WIDTH, 1, ' ', tb_attr);

    /* Start button */
    gui_draw_button(1, VGA_HEIGHT - 1, 9, " Coast ", 0);

    /* Separator */
    vga_put_attr_at(11, VGA_HEIGHT - 1, 0xB3, tb_attr);

    /* Window list slots */
    for (int i = 0; i < win_count && i < 5; i++) {
        int pressed = (i == active_win);
        gui_draw_button(13 + i * 13, VGA_HEIGHT - 1, 11,
                        windows[i].title, pressed);
    }

    /* Uptime on right */
    char uptbuf[16];
    uint32_t secs = g_ticks / 100;
    uint_to_dec(secs / 60, uptbuf, 2);
    uptbuf[2] = ':';
    uint_to_dec(secs % 60, uptbuf + 3, 2);
    uptbuf[5] = 0;

    uint8_t up_attr = vga_attr(VGA_YELLOW, GUI_TASKBAR_BG);
    int ux = VGA_WIDTH - 8;
    const char *up_label = "Up:";
    for (int i = 0; up_label[i]; i++)
        vga_put_attr_at(ux + i, VGA_HEIGHT - 1, up_label[i], up_attr);
    for (int i = 0; uptbuf[i]; i++)
        vga_put_attr_at(ux + 3 + i, VGA_HEIGHT - 1, uptbuf[i], up_attr);
}

/* ============================================================
 * WINDOW  -  title bar + border + content
 * ============================================================ */
void gui_draw_window(Window *win) {
    if (!win->visible) return;

    /* Shadow (dark offset) */
    vga_fill_rect(win->x + 1, win->y + 1, win->w, win->h,
                  ' ', vga_attr(VGA_BLACK, VGA_DARK_GREY));

    /* Window body */
    vga_fill_rect(win->x, win->y, win->w, win->h,
                  ' ', vga_attr(GUI_TEXT_FG, GUI_WINDOW_BG));

    /* Border */
    vga_draw_box(win->x, win->y, win->w, win->h,
                 vga_attr(GUI_BORDER, GUI_WINDOW_BG));

    /* Title bar */
    uint8_t tb = win->active
               ? vga_attr(GUI_TITLE_FG,  GUI_TITLE_BG)
               : vga_attr(VGA_DARK_GREY, VGA_LIGHT_GREY);
    vga_fill_rect(win->x + 1, win->y, win->w - 2, 1, ' ', tb);
    /* Title text */
    int tlen = str_len(win->title);
    int tx   = win->x + (win->w - tlen) / 2;
    for (int i = 0; win->title[i]; i++)
        vga_put_attr_at(tx + i, win->y, win->title[i], tb);

    /* Close button [X] */
    uint8_t xbtn = vga_attr(VGA_YELLOW, VGA_RED);
    vga_put_attr_at(win->x + win->w - 3, win->y, '[', xbtn);
    vga_put_attr_at(win->x + win->w - 2, win->y, 'X', xbtn);
    vga_put_attr_at(win->x + win->w - 1, win->y, ']', xbtn);

    /* Content area */
    if (win->draw_content)
        win->draw_content(win->x + 1, win->y + 1,
                          win->w - 2, win->h - 2);
}

/* ============================================================
 * BUILT-IN APP CONTENT RENDERERS
 * ============================================================ */
void draw_about_content(int x, int y, int w, int h) {
    (void)w; (void)h;
    uint8_t a = vga_attr(VGA_BLUE, GUI_WINDOW_BG);
    uint8_t b = vga_attr(VGA_BLACK, GUI_WINDOW_BG);
    uint8_t c = vga_attr(VGA_RED, GUI_WINDOW_BG);

    vga_puts_at(x+2, y+1, ""); /* helper */
    #define PA(px,py,s,at) { const char*_s=(s); for(int _i=0;_s[_i];_i++) vga_put_attr_at((px)+_i,(py),_s[_i],(at)); }
    PA(x+2, y+1,  "   *** CoastOS v1.0 ***",   a)
    PA(x+2, y+3,  "  Architecture : 32-bit IA-32",  b)
    PA(x+2, y+4,  "  Display      : VGA Text 80x25", b)
    PA(x+2, y+5,  "  Colour Depth : 4-bit (16 col)", b)
    PA(x+2, y+6,  "  Kernel       : Monolithic C",   b)
    PA(x+2, y+7,  "  Boot         : Custom MBR",     b)
    PA(x+2, y+9,  "  (C) 2025 CoastOS Project",      c)
    PA(x+2, y+11, "  [  OK  ]",  vga_attr(GUI_BTN_FG, GUI_BTN_BG))
    #undef PA
}

void draw_terminal_content(int x, int y, int w, int h) {
    (void)w;
    uint8_t a = vga_attr(VGA_GREEN, VGA_BLACK);
    uint8_t p = vga_attr(VGA_WHITE, VGA_BLACK);
    vga_fill_rect(x, y, w - 0, h, ' ', vga_attr(VGA_WHITE, VGA_BLACK));
    #define TA(px,py,s,at) { const char*_s=(s); for(int _i=0;_s[_i];_i++) vga_put_attr_at((px)+_i,(py),_s[_i],(at)); }
    TA(x, y,   "CoastOS Terminal v1.0", a)
    TA(x, y+1, "Type 'help' for commands.", p)
    TA(x, y+2, "--------------------------------", a)
    TA(x, y+4, "coast:~$ help", p)
    TA(x, y+5, "  about   - about CoastOS", a)
    TA(x, y+6, "  ver     - kernel version", a)
    TA(x, y+7, "  colour  - test palette", a)
    TA(x, y+8, "  reboot  - restart system", a)
    TA(x, y+10,"coast:~$ _", p)
    #undef TA
}

void draw_info_content(int x, int y, int w, int h) {
    (void)w; (void)h;
    uint8_t a = vga_attr(VGA_BLUE,  GUI_WINDOW_BG);
    uint8_t b = vga_attr(VGA_BLACK, GUI_WINDOW_BG);
    #define IA(px,py,s,at) { const char*_s=(s); for(int _i=0;_s[_i];_i++) vga_put_attr_at((px)+_i,(py),_s[_i],(at)); }
    IA(x+1, y+1, "System Information", a)
    IA(x+1, y+3, "CPU   : i686 / 32-bit", b)
    IA(x+1, y+4, "RAM   : 640 KB (conv)", b)
    IA(x+1, y+5, "Video : VGA 0xB8000",   b)
    IA(x+1, y+6, "PIT   : 100 Hz",        b)
    IA(x+1, y+7, "PS/2  : Keyboard OK",   b)
    IA(x+1, y+9, "Build : " __DATE__,      vga_attr(VGA_DARK_GREY, GUI_WINDOW_BG))
    #undef IA
}

void draw_colours_content(int x, int y, int w, int h) {
    (void)w; (void)h;
    uint8_t title_a = vga_attr(VGA_BLACK, GUI_WINDOW_BG);
    vga_put_attr_at(x + 2, y + 1, 'C', title_a);
    /* palette swatch blocks */
    for (int col = 0; col < 16; col++) {
        int cx = x + 1 + (col % 8) * 4;
        int cy = y + 3 + (col / 8) * 2;
        uint8_t swatch = vga_attr((vga_color_t)col, (vga_color_t)col);
        vga_put_attr_at(cx,     cy, 0xDB, swatch);
        vga_put_attr_at(cx + 1, cy, 0xDB, swatch);
        vga_put_attr_at(cx + 2, cy, 0xDB, swatch);
        char num[3];
        num[0] = (col < 10) ? ' ' : '0' + col / 10;
        num[1] = '0' + col % 10;
        num[2] = 0;
        vga_put_attr_at(cx,     cy + 1, num[0],
                        vga_attr(VGA_DARK_GREY, GUI_WINDOW_BG));
        vga_put_attr_at(cx + 1, cy + 1, num[1],
                        vga_attr(VGA_DARK_GREY, GUI_WINDOW_BG));
    }
    uint8_t la = vga_attr(VGA_BLACK, GUI_WINDOW_BG);
    const char *lbl = "16-colour VGA palette";
    for (int i = 0; lbl[i]; i++)
        vga_put_attr_at(x + 1 + i, y + 8, lbl[i], la);
}

/* ============================================================
 * WINDOW MANAGEMENT
 * ============================================================ */
void gui_open_window(int idx) {
    if (idx < 0 || idx >= win_count) return;
    windows[idx].visible = 1;
    /* deactivate others */
    for (int i = 0; i < win_count; i++) windows[i].active = 0;
    windows[idx].active = 1;
    active_win = idx;
}

void gui_close_window(int idx) {
    if (idx < 0 || idx >= win_count) return;
    windows[idx].visible = 0;
    windows[idx].active  = 0;
    if (active_win == idx) active_win = -1;
}

static void register_window(int x, int y, int w, int h,
                             const char *title,
                             void (*content)(int,int,int,int)) {
    int idx = win_count++;
    windows[idx].x = x; windows[idx].y = y;
    windows[idx].w = w; windows[idx].h = h;
    str_copy(windows[idx].title, title, 32);
    windows[idx].draw_content = content;
    windows[idx].visible = 0;
    windows[idx].active  = 0;
}

/* ============================================================
 * INIT + EVENT LOOP
 * ============================================================ */
void gui_init(void) {
    win_count  = 0;
    active_win = -1;

    /* Register built-in app windows */
    register_window(10, 3,  40, 16, "About CoastOS",  draw_about_content);
    register_window(8,  3,  45, 14, "Terminal",        draw_terminal_content);
    register_window(15, 4,  38, 14, "System Info",     draw_info_content);
    register_window(12, 3,  40, 13, "Colour Palette",  draw_colours_content);
}

static void redraw_all(void) {
    gui_draw_desktop();
    for (int i = 0; i < win_count; i++)
        gui_draw_window(&windows[i]);
    gui_draw_taskbar();
}

void gui_run(void) {
    redraw_all();

    /* Show About window on startup */
    gui_open_window(0);
    redraw_all();

    for (;;) {
        /* Poll keyboard */
        uint8_t key = keyboard_poll();

        switch (key) {
            case '1': gui_open_window(0); break;
            case '2': gui_open_window(1); break;
            case '3': gui_open_window(2); break;
            case '4': gui_open_window(3); break;
            case 'q': case 'Q':
                if (active_win >= 0) gui_close_window(active_win);
                break;
            case '\t':
                /* Cycle windows */
                if (win_count > 0) {
                    int nxt = (active_win + 1) % win_count;
                    gui_open_window(nxt);
                }
                break;
            default: break;
        }

        /* Update uptime display every tick */
        gui_draw_taskbar();

        if (key) redraw_all();

        asm volatile("hlt");   /* wait for next IRQ */
    }
}
