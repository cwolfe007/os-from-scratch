#!/bin/bash

FILE="test-boot.bin"

# create 512 sector binary
dd if=/dev/zero of="${FILE}" bs=1 count=512

# print hex for endless loop
printf '\xe9\xfd\xff' | dd of="${FILE}" bs=1 conv=notrunc

#write the magic number
printf '\x55\xaa' | dd of="${FILE}" bs=1 seek=510 conv=notrunc

xxd "${FILE}"
