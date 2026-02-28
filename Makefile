# This builds binary of our kernel from dependent object files

# when no param is given, make assumes first target at nearest top of file
all: os-image

run: os-image 
	qemu-system-x86_64 -drive format=raw,file="$<" #-nographic -serial mon:stdio

os-image: boot_sect.bin kernel.bin
	cat $^ > $@

# Syntax = kernel.bin (file generated) : kernel_entry.o kernel.o (files needed to build kernel.bin)
# Build the kenernal binary
kernel.bin: kernel_entry.o kernel.o
	ld -m elf_i386 -o kernel.bin -Ttext 0x1000 $^ --oformat binary
# $^ = kernel_entry.o kernel.o

# Build our kernel entry object file
kernel.o: kernel/kernel.c
	gcc -ffreestanding -m32 -c $< -o $@
# $< = kernel.c $@ = kernel.o

kernel_entry.o: kernel/kernel_entry.asm
	nasm $< -f elf -o $@

boot_sect.bin: boot/boot_sect.asm
	nasm $< -f bin -o $@

clean:
	rm *.o *.bin
