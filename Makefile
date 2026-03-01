# This builds binary of our kernel from dependent object files

# Add wildcard and code detection logic
# Allows us to find code automatically w/o updating the makefile frequently
#
C_SOURCES = $(wildcard kernel/*.c drivers/*.c )
HEADERS = $( kernel/*.h drivers/*.h )

# TODO: make sources dependent on header files
#
# Convert <file>.c to <file>.o to give list of object files to build
OBJ = ${C_SOURCES:.c=.o}

# when no param is given, make assumes first target at nearest top of file
all: run

run: os-image 
	qemu-system-x86_64 -drive format=raw,file="$<" #-nographic -serial mon:stdio

os-image: boot/boot_sect.bin kernel.bin
	cat $^ > $@

# Syntax = kernel.bin (file generated) : kernel_entry.o kernel.o (files needed to build kernel.bin)
# Build the kenernal binary
kernel.bin: kernel/kernel_entry.o ${OBJ}
	ld -m elf_i386 -o kernel.bin -Ttext 0x1000 $^ --oformat binary
# $^ = kernel_entry.o kernel.o

# Build our kernel entry object file
%.o: %.c ${HEADERS}
	gcc -ffreestanding -m32 -c $< -o $@
# $< = kernel.c $@ = kernel.o

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm 
	nasm $< -f bin  -o $@

clean:
	rm *.o *.bin os-image
	rm kernel/*.o boot/*.bin drivers/*.o
