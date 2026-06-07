/* CoastOS Kernel Linker Script */
ENTRY(_start)

SECTIONS {
    . = 0x1000;

    .text : {
        /* Entry first */
        kernel/kernel_entry.o (.text)
        *(.text)
    }

    .rodata : { *(.rodata) }

    .data : { *(.data) }

    .bss : {
        *(.bss)
        *(COMMON)
    }
}
