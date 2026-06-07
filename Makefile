# ============================================================
# CoastOS Build System
# ============================================================
# Requirements:
#   nasm, i686-elf-gcc (or cross-compiler), i686-elf-ld
#   xorriso, grub-mkrescue  (for ISO target)
# ============================================================

CC      = i686-elf-gcc
LD      = i686-elf-ld
NASM    = nasm
XORRISO = xorriso

CFLAGS  = -m32 -ffreestanding -O2 -Wall -Wextra \
           -fno-stack-protector -fno-pic \
           -Ikernel

LDFLAGS = -m elf_i386 -T build/linker.ld --oformat binary

KERNEL_SRCS = kernel/kernel_entry.asm \
              kernel/kernel.c \
              kernel/vga.c \
              kernel/gui.c \
              kernel/keyboard.c \
              kernel/timer.c

OBJS = build/kernel_entry.o \
       build/kernel.o \
       build/vga.o \
       build/gui.o \
       build/keyboard.o \
       build/timer.o

.PHONY: all clean iso

all: build/coastos.img

## Bootloader
build/boot.bin: boot/boot.asm
	@mkdir -p build
	$(NASM) -f bin -o $@ $<

## Kernel object files
build/kernel_entry.o: kernel/kernel_entry.asm
	@mkdir -p build
	$(NASM) -f elf32 -o $@ $<

build/%.o: kernel/%.c
	@mkdir -p build
	$(CC) $(CFLAGS) -c -o $@ $<

## Link kernel to flat binary at 0x1000
build/kernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

## Combine bootloader + kernel into disk image
build/coastos.img: build/boot.bin build/kernel.bin
	cat build/boot.bin build/kernel.bin > $@
	# Pad to floppy size (1.44 MB) so QEMU is happy
	truncate -s 1474560 $@
	@echo ""
	@echo "  ✓  build/coastos.img  (raw disk image)"

## GRUB ISO (run in GitHub Codespaces or Linux with xorriso+grub)
iso: build/coastos.iso

build/coastos.iso: build/kernel.bin iso_root/boot/grub/grub.cfg
	cp build/kernel.bin iso_root/boot/kernel.bin
	grub-mkrescue -o $@ iso_root
	@echo ""
	@echo "  ✓  build/coastos.iso  (bootable ISO)"

## Run in QEMU (raw image)
run: build/coastos.img
	qemu-system-i386 -drive format=raw,file=build/coastos.img

## Run ISO in QEMU
run-iso: build/coastos.iso
	qemu-system-i386 -cdrom build/coastos.iso

clean:
	rm -rf build/*.o build/*.bin build/*.img build/*.iso
	rm -f iso_root/boot/kernel.bin
