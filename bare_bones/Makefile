run: kernel.bin
	qemu-system-x86_64 -drive format=raw,file="$<" -nographic -serial mon:stdio

kernel.bin: boot.o kernel.o
	/home/cwolfe/opt/cross/bin/i686-elf-ld -o $@  $^ --oformat binary
boot.o: boot.asm
	nasm -felf32 $< -o $@ 


kernel.o: kernel/kernel.c
	/home/cwolfe/opt/cross/bin/i686-elf-gcc -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra

# kernel.o: kernel/kernel.asm
# 	nasm -felf32 $< -o $@ 

clean:
	rm -fv boot.o kernel.o
