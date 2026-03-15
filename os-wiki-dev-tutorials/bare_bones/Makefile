run: os-image 
	qemu-system-i386 -kernel "$<" #-nographic -serial mon:stdio

os-image: boot.o kernel.o
	i686-elf-gcc -T linker.ld -o $@ -ffreestanding -O2 -nostdlib $^ -lgcc  

boot.o: boot.asm
	nasm -felf32 $< -o $@ 

kernel.o: kernel/kernel.c
	i686-elf-gcc -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra

clean:
	rm -fv boot.o kernel.o kernel.bin os-image
