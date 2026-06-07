# 🌊 CoastOS v1.0

A custom 32-bit operating system with a text-mode GUI shell, written from scratch in C and x86 assembly.

```
   ____                 _    ___  ____
  / ___|___   __ _ ___ | |_ / _ \/ ___|
 | |   / _ \ / _` / __|| __| | | \___ \
 | |__| (_) | (_| \__ \| |_| |_| |___) |
  \____\___/ \__,_|___/ \__|\___/|____/
```

## Features

- **Custom MBR bootloader** — hand-written NASM, fits in 512 bytes
- **32-bit protected-mode kernel** — C kernel with IDT/PIT/PS2
- **VGA text-mode GUI** — 80×25, 16-colour, full CP437 box drawing
- **Desktop** — cyan tiled background, icons, top menu bar
- **Windows** — draggable bordered windows with coloured title bars
- **Buttons** — 3-D raised/pressed buttons using attribute tricks
- **Built-in apps** — About, Terminal, System Info, Colour Palette
- **Taskbar** — window switcher + uptime counter

## Repository Structure

```
coastos/
├── boot/
│   └── boot.asm          # Stage-1 MBR bootloader (NASM)
├── kernel/
│   ├── kernel_entry.asm  # 32-bit entry, sets stack, calls kmain()
│   ├── kernel.c/h        # kmain(), boot splash
│   ├── vga.c/h           # VGA driver, box drawing, fill, colour
│   ├── gui.c/h           # Desktop, windows, buttons, icons
│   ├── keyboard.c/h      # PS/2 keyboard driver
│   └── timer.c/h         # PIT 100 Hz timer + IDT
├── build/
│   └── linker.ld         # Flat-binary linker script (origin 0x1000)
├── iso_root/
│   └── boot/grub/grub.cfg
├── .devcontainer/
│   └── devcontainer.json # GitHub Codespaces config
├── .github/workflows/
│   └── build.yml         # CI → builds ISO + uploads artifact
├── Makefile
└── README.md
```

## Quick Start (GitHub Codespaces)

1. **Fork / upload this repo to GitHub**
2. Click **Code → Codespaces → Create codespace on main**
3. Wait for the container to install dependencies (~2 min)
4. In the terminal:

```bash
# Build raw disk image
make all

# Build bootable ISO  ← this is your .iso file
make iso

# Download  build/coastos.iso  from the Explorer panel
```

The ISO can be burned to USB with [Rufus](https://rufus.ie) or run in QEMU:

```bash
qemu-system-i386 -cdrom build/coastos.iso
```

## Build Locally (Linux)

```bash
sudo apt install nasm gcc gcc-multilib binutils xorriso grub-pc-bin
make all    # → build/coastos.img
make iso    # → build/coastos.iso
make run    # → QEMU (needs qemu-system-i386)
```

## Keyboard Controls (GUI)

| Key | Action |
|-----|--------|
| `1` | Open About window |
| `2` | Open Terminal window |
| `3` | Open System Info window |
| `4` | Open Colour Palette window |
| `Tab` | Cycle through windows |
| `Q` | Close active window |

## CI / GitHub Actions

Every push automatically builds the ISO and uploads it as a downloadable artifact under **Actions → Build CoastOS ISO → Artifacts**.

## Roadmap

- [ ] Mouse support (PS/2)
- [ ] File system (FAT12 on floppy)
- [ ] More apps (calculator, text editor)
- [ ] Multiboot2 header
- [ ] Sound (PC speaker beeps)

---
*CoastOS — built for learning, built for fun.*
