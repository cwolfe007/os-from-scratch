#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <file.asm>"
  exit 1
fi

ASM_FILE="$1"
BIN_FILE="${ASM_FILE%.*}.bin"
KERNEL_FILE="kernel"
K_C_FILE="${KERNEL_FILE}.c"
K_O_FILE="${KERNEL_FILE}.o"
K_B_FILE="${KERNEL_FILE}.bin"
OS_IMAGE_BIN="os-image.bin"

# Compile the boot sector
nasm "$ASM_FILE" -f bin -o "$BIN_FILE"

# Compile the kernel and link to 0x1000
gcc -ffreestanding -c $K_C_FILE -o $K_O_FILE
ld -o $K_B_FILE -Ttext 0x1000 $K_O_FILE --oformat binary

# Create the kernel image
cat $BIN_FILE $K_B_FILE >$OS_IMAGE_BIN

# boot and ... well ... yolo
qemu-system-x86_64 -drive format=raw,file="$OS_IMAGE_BIN" #-nographic -serial mon:stdio
