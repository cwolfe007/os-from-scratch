#!/bin/bash
set -xe

if [ -z "kernel.c" ] || [ -z "kernel.asm" ]; then
  echo "define your kernel (kernel.c) and boot loader (kernel.asm)"
  exit 1
fi

KERNEL_FILE="kernel"
ASM_FILE="${KERNEL_FILE}.asm"
ASM_FILE_ENRTY="${KERNEL_FILE}-entry.asm"
BIN_FILE="${ASM_FILE%.*}-boot.bin"
K_C_FILE="${KERNEL_FILE}.c"
K_O_FILE="${KERNEL_FILE}.o"
K_O_ENTRY_FILE="${KERNEL_FILE}-entry.o"
K_B_FILE="${KERNEL_FILE}.bin"
OS_IMAGE_BIN="os-image.bin"

# Compile the boot sector
nasm "$ASM_FILE" -f bin -o "$BIN_FILE"
# Link with elf so the boot loader knows where to find main
nasm "$ASM_FILE_ENRTY" -f elf -o "$K_O_ENTRY_FILE"

# Compile the kernel (in 32bit) and link to 0x1000
gcc -ffreestanding -c $K_C_FILE -o $K_O_FILE -m32
ld -m elf_i386 -o $K_B_FILE -Ttext 0x1000 $K_O_ENTRY_FILE $K_O_FILE --oformat binary

# Create the kernel image
cat $BIN_FILE $K_B_FILE >"$OS_IMAGE_BIN"

# boot and ... well ... yolo
qemu-system-x86_64 -drive format=raw,file="$OS_IMAGE_BIN" #-nographic -serial mon:stdio
