; Declare multiboot header
MBALIGN equ 1 << 0 ; align loaded module page boundaries
MEMINFO equ 1 << 1 ; provide memory map
MBFLAGS equ MBALIGN | MEMINFO ; sets the multiboot 'flag'
MAGIC equ 0x1BADB002 ; 'magic number' to tell the bootloader where to find header
CHECKSUM equ -(MAGIC + MBFLAGS) ; Prove we are multiboot
                                ; CHECKSUM + MAGIC + MBFLAGS = 0 

; Declare a multiboot header that maeks the program as a kernel
; The bootloader searches for this signature in the first 8KiB 
; off the kernel file, aligned at a 32 bit boundary.
; The signature is in its own section so the header can be forced
; to be within the first 8 KiB of the kernel file
section .multiboot
align 4
  dd MAGIC
  dd MBFLAGS
  dd CHECKSUM

; The multiboot standard does not define where the stack register
; is defined (so no esp stack pointer address)
; This creates a 16384 byte stack, this arms to contain the kernel code
; Not x86 stacks move "down" memory, so we must ensure alignment to 
; prevent unaligned behavior
section .bss
align 16
stack_bottom:
resb 16384 ; 16KiB stack
stack_top:

; The linker script specifies _start as the entry point to the kernel,
; the bootloader will jump to this location once the kernel is loaded (from protected mode?)
; We specify space here to load the kernel function, but since the bootloader is "gone"
; this funciton will not return anything and we will jump to the kernel location
; in memory
section .text
global _start:function (_start.end - _start)
_start:
  ; The bootloader in protected mode (32bit <- 16bit realmode)
  ; All the BIOS a functions are "gone" and now the kernel is in
  ; full control. (see os-from-scratch/ for example real mode -> protected mode transition)
  ;
  ; Move the esp registart to the top of our .bss stack
  mov esp, stack_top

  extern kernel_main
  call kernel_main
  ; The boot is done and the kernel is done.
  ; cli = will clear interupts. The gdt table is loaded and we will
  ; let the kernel do the rest. so now just loop forever
  cli

.hang:
  jmp .hang

.end:

