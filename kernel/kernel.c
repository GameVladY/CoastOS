/* =============================================================
 * CoastOS - Kernel Entry Point
 * kernel/kernel.c
 *
 * Initialises hardware, sets up VGA text mode,
 * then launches the CoastOS GUI shell.
 * ============================================================= */

#include "kernel.h"
#include "vga.h"
#include "gui.h"
#include "keyboard.h"
#include "timer.h"

/* Kernel main - called from boot.asm after entering PM */
void kmain(void) {
    /* Initialise subsystems */
    vga_init();
    timer_init(100);       /* 100 Hz tick */
    keyboard_init();

    /* Boot splash */
    vga_clear(VGA_BLACK);
    boot_splash();

    /* Hand off to GUI shell */
    gui_init();
    gui_run();             /* event loop - never returns */

    /* Halt if we somehow return */
    for (;;) { asm volatile("hlt"); }
}

/* Boot splash screen rendered in 32-bit protected-mode text */
void boot_splash(void) {
    vga_set_color(VGA_CYAN, VGA_BLACK);
    vga_puts_at(28, 8,  "  ____                 _    ___  ____  ");
    vga_puts_at(28, 9,  " / ___|___   __ _ ___ | |_ / _ \\/ ___| ");
    vga_puts_at(28, 10, "| |   / _ \\ / _` / __|| __| | | \\___ \\ ");
    vga_puts_at(28, 11, "| |__| (_) | (_| \\__ \\| |_| |_| |___) |");
    vga_puts_at(28, 12, " \\____\\___/ \\__,_|___/ \\__|\\___/|____/ ");

    vga_set_color(VGA_WHITE, VGA_BLACK);
    vga_puts_at(34, 14, "CoastOS v1.0 - 32-bit");
    vga_set_color(VGA_LIGHT_GREY, VGA_BLACK);
    vga_puts_at(30, 15, "A clean, colourful operating system");

    /* Fake loading bar */
    vga_set_color(VGA_GREEN, VGA_BLACK);
    vga_puts_at(27, 17, "[");
    vga_puts_at(53, 17, "]");
    for (int i = 0; i < 25; i++) {
        timer_sleep(2);
        vga_putchar_at(28 + i, 17, '#');
    }

    vga_set_color(VGA_YELLOW, VGA_BLACK);
    vga_puts_at(31, 19, "Starting GUI shell...");
    timer_sleep(50);
}
