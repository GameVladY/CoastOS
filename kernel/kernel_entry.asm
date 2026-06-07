; =============================================================
; CoastOS - Kernel ASM Entry Point
; kernel/kernel_entry.asm
;
; Linked first so it sits at 0x1000 where boot.asm jumps.
; Sets up a stack and calls C kmain().
; =============================================================
[BITS 32]

global _start
extern kmain

_start:
    ; Set up stack
    mov esp, kernel_stack_top
    call kmain
    hlt

; Reserve 16 KB kernel stack
section .bss
align 4
kernel_stack_bottom:
    resb 16384
kernel_stack_top:
