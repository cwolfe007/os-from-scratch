#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <file.asm>"
  exit 1
fi

ASM_FILE="$1"
BIN_FILE="${ASM_FILE%.*}.bin"

nasm "$ASM_FILE" -f bin -o "$BIN_FILE"
qemu-system-x86_64 -drive format=raw,file="$BIN_FILE" #-nographic -serial mon:stdio
