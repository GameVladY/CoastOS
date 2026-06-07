# ============================================================
# CoastOS Build System
# ============================================================
# Works with system gcc (no cross-compiler needed).
# In Codespaces/Ubuntu: sudo apt install nasm gcc gcc-multilib
#                        binutils xorriso grub-pc-bin grub-common
# ============================================================

CC      = gcc
LD      = ld
NASM    = nasm
XORRISO = xorriso

CFLAGS  = -m32 -ffreestanding -O2 -Wall -Wextra \
           -fno-stack-protector -fno-pic -fno-pie \
           -nostdlib -nostdinc \
           -Ikernel

# ld flag: -melf_i386  (one dash, no space — GNU ld syntax)
LDFLAGS = -melf_i386 -T build/linker.ld --oformat binary

OBJS = build/kernel_entry.o \
       build/kernel.o \
       build/vga.o \
       build/gui.o \
       build/keyboard.o \
       build/timer.o

.PHONY: all clean iso deps

## Install build deps (Codespaces / Ubuntu)
deps:
	sudo apt-get update -qq
	sudo apt-get install -y nasm gcc gcc-multilib binutils \
	    xorriso grub-pc-bin grub-common

all: build/coastos.img

## ── Bootloader ──────────────────────────────────────────────
build/boot.bin: boot/boot.asm
	@mkdir -p build
	$(NASM) -f bin -o $@ $<

## ── Kernel object files ─────────────────────────────────────
build/kernel_entry.o: kernel/kernel_entry.asm
	@mkdir -p build
	$(NASM) -f elf32 -o $@ $<

build/%.o: kernel/%.c
	@mkdir -p build
	$(CC) $(CFLAGS) -c -o $@ $<

## ── Link kernel flat binary at 0x1000 ───────────────────────
build/kernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

## ── Raw disk image ──────────────────────────────────────────
build/coastos.img: build/boot.bin build/kernel.bin
	cat build/boot.bin build/kernel.bin > $@
	truncate -s 1474560 $@
	@echo ""
	@echo "  ✓  build/coastos.img  (raw floppy image)"

## ── GRUB ISO ────────────────────────────────────────────────
iso: build/coastos.iso

build/coastos.iso: build/kernel.bin iso_root/boot/grub/grub.cfg
	cp build/kernel.bin iso_root/boot/kernel.bin
	grub-mkrescue -o $@ iso_root 2>/dev/null
	@echo ""
	@echo "  ✓  build/coastos.iso  (bootable ISO)"

## ── QEMU helpers ─────────────────────────────────────────────
run: build/coastos.img
	qemu-system-i386 -drive format=raw,file=build/coastos.img

run-iso: build/coastos.iso
	qemu-system-i386 -cdrom build/coastos.iso

## ── Clean ────────────────────────────────────────────────────
clean:
	rm -rf build/*.o build/*.bin build/*.img build/*.iso
	rm -f iso_root/boot/kernel.bin
