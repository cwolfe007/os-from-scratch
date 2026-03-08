boot.o: boot.asm
	nasm -felf32 $< -o $@ 

kernel.o: kernel/kernel.asm
	nasm -felf32 $< -o $@ 

clean:
	rm -fv boot.o kernel.o
