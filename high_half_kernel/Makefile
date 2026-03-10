PREFIX  = $(HOME)/opt/cross
TARGET  = i686-elf
CC      = $(PREFIX)/bin/$(TARGET)-gcc
AS      = $(PREFIX)/bin/$(TARGET)-as

KERNEL_DIR = ./kernel
CFLAGS  = -ffreestanding -O2 -Wall -Wextra -std=gnu99

.PHONY: run clean

run: os-image
	qemu-system-i386 -kernel os-image

os-image: boot.o kernel.o
	$(CC) -T linker.ld -o $@ -ffreestanding -O2 -nostdlib $^ -lgcc

boot.o: boot.s
	$(AS) $< -o $@

kernel.o: $(KERNEL_DIR)/kernel.c
	$(CC) -c $< -o $@ $(CFLAGS)

clean:
	rm -fv boot.o kernel.o os-image
