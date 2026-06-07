/* CoastOS - PS/2 Keyboard Driver */
#ifndef KEYBOARD_H
#define KEYBOARD_H
#include <stdint.h>
void    keyboard_init(void);
uint8_t keyboard_poll(void);   /* Returns ASCII, 0 if no key */
#endif
