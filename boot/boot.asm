; ============================================================
; CoastOS Bootloader - Stage 1
; Displays boot message, then hands off to kernel
; Assembled with NASM, burns to MBR (512 bytes)
; ============================================================

[BITS 16]
[ORG 0x7C00]

KERNEL_OFFSET equ 0x1000   ; kernel loaded at 0x1000:0000

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Set video mode 3 (80x25 text, colour)
    mov ax, 0x0003
    int 0x10

    ; Print boot banner
    mov si, msg_boot
    call print_string

    ; Load kernel from disk (sector 2 onwards, 32 sectors)
    call load_kernel

    ; Switch to protected mode
    call switch_pm

    jmp $                  ; Should never reach here

; ----------------------------------------------------------
; print_string  SI = pointer to null-terminated string
; ----------------------------------------------------------
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x0F           ; bright white on black
    int 0x10
    jmp print_string
.done:
    ret

; ----------------------------------------------------------
; load_kernel  - uses INT 13h to read sectors
; ----------------------------------------------------------
load_kernel:
    mov ah, 0x02           ; BIOS read sectors
    mov al, 32             ; read 32 sectors
    mov ch, 0              ; cylinder 0
    mov cl, 2              ; start at sector 2
    mov dh, 0              ; head 0
    mov dl, 0x80           ; first hard disk (use 0x00 for floppy)
    mov bx, KERNEL_OFFSET
    int 0x13
    jc disk_error
    ret

disk_error:
    mov si, msg_disk_err
    call print_string
    jmp $

; ----------------------------------------------------------
; switch_pm  - enter 32-bit protected mode
; ----------------------------------------------------------
switch_pm:
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:init_pm

[BITS 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x90000
    mov esp, ebp
    call KERNEL_OFFSET     ; jump to kernel
    jmp $

; ----------------------------------------------------------
; GDT
; ----------------------------------------------------------
gdt_start:
    dd 0x0, 0x0            ; null descriptor

gdt_code:
    dw 0xFFFF              ; limit low
    dw 0x0000              ; base low
    db 0x00                ; base mid
    db 10011010b           ; access byte
    db 11001111b           ; flags + limit high
    db 0x00                ; base high

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; ----------------------------------------------------------
; Strings
; ----------------------------------------------------------
msg_boot     db 13, 10, '  CoastOS v1.0 - Booting...', 13, 10, 0
msg_disk_err db 13, 10, '  [ERROR] Disk read failed!', 0

; ----------------------------------------------------------
; Boot sector padding + signature
; ----------------------------------------------------------
times 510 - ($ - $$) db 0
dw 0xAA55
