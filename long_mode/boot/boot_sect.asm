%macro print_disk 3
  pusha
  mov bx, %1 
  mov dh, %2 ; sectors to load
  mov dl, [BOOT_DRIVE]; load the boot dirve
  call disk_load
  add bx, %3
  call print_string
  popa
%endmacro

; Kernel Boot Loader
[org 0x7c00]

  KERNEL_OFFSET equ 0x1000 ; This is the memory offset which we laod our kernel
  STACK_POINTER equ 0x8000 ; Bottom of the stack
  DISK_ADDR     equ 0x9000 ; Disk address

  mov [BOOT_DRIVE], dl ; Save disk loader contents to DL

  ; set up the stack
  mov bp, STACK_POINTER ; save base pointer to x9000
  mov sp, bp ; set stack point to base pointer 

  ; print_disk DISK_ADDR, 1, MSG_REAL_MODE ; address, sectors, offset

  call load_kernel
  call switch_to_lm 

  jmp $

; Include routines 
%include "boot/print_string/print_string.asm"
%include "boot/long_mode/gdt.asm"
%include "boot/long_mode/print_string_lm.asm"
%include "boot/long_mode/switch_to_lm.asm"
%include "boot/disk/disk_load.asm"

[bits 16]

load_kernel:

  mov dl, [BOOT_DRIVE] ; Load the boot drive sector from disk where our kernel lives

  ; print_disk DISK_ADDR, 9, MSG_LONG_MODE - MSG_REAL_MODE ; address, sectors, offset
  mov bx, KERNEL_OFFSET
  mov dh, 9 ; Load the first 9 sectors G(1-9 seem valid) (excluding bootdrive)
  mov dl, [BOOT_DRIVE] ; Load the boot drive sector from disk where our kernel lives
  call disk_load
  ret

; Start to switch to protected_mode
[bits 64]
; Area to land after swithcing to protected_mode

BEGIN_LM:
  mov rbx, MSG_LONG_MODE ;print message indicating we landed in protected_mode as epxected 
  call print_string_lm

  call KERNEL_OFFSET ; Jump to where we *think* the kernel is, YOLO
  ; call checkCPUID 

  ; note because we are entering long mode, we will skip paging in protected_mode(32 bit mode)
  ; 64 bit page table is double to size of the 32 bit table
  ; For this example we will skip the higher half kernel for now
  ; PML4T_ADDR equ 0x1000; We will map the first 2MiB of memory 
  ; SIZE_OF_PAGE_TABLE equ 4096
  ; ;
  ; mov rdi, PML4T_ADDR
  ; mov cr3, rdi
  ; xor rax, rax
  ; mov rcx, SIZE_OF_PAGE_TABLE
  ; rep stosd ; write 4 * SIZE_OF_PAGE_TABLE bytes, which is expected to be enough space
  ; mov rdi, cr3 ; reset di back to beggining of page table

  jmp $


; Global vars
MSG_LONG_MODE db "64 bit long mode - ",0
BOOT_DRIVE db 0
times 510-($-$$) db 0
dw 0xaa55
; MSG_REAL_MODE db "16 bit long mode - ",0
;MSG_LOAD_KERNEL db "Loading the kernel now",0

