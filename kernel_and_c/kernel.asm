; Kernel Boot Loader
[org 0x7c00]

KERNEL_OFFSET equ 0x1000 ; This is the memory offset which we laod our kernel
  mov [BOOT_DRIVE], dl ; Save disk loader contents to DL

  ; set up the stack
  mov bp, 0x9000 ; save base pointer to x9000
  mov sp, bp ; set stack point to base pointer 

  mov bx, MSG_REAL_MODE ; 
  call print_string

  call load_kernel

  call switch_to_pm 

  jmp $

; Include routines 
%include "../print_string_example/print_string.asm"
%include "../protected_mode/gdt.asm"
%include "../protected_mode/print_string_pm.asm"
%include "../protected_mode/switch_to_pm.asm"
%include "../disk_exmaple/disk_load.asm"

[bits 16]

load_kernel:
  mov bx, MSG_LOAD_KERNEL
  call print_string

  ;Prepare sectors for disk load routines
  
  mov bx, KERNEL_OFFSET
  mov dh, 15 ; Load the first 15 sectors (excluding bootdrive)
  mov dl, [BOOT_DRIVE] ; Load the boot drive sector from disk where our kernel lives
  call disk_load
  ret

; Start to switch to protected_mode
[bits 32]
; Area to land after swithcing to protected_mode

BEGIN_PM:
  mov ebx, MSG_PROT_MODE ;print message indicating we landed in protected_mode as epxected 
  call print_string_pm

  call KERNEL_OFFSET ; Jump to where we *think* the kernel is, YOLO

  jmp $

; Global vars
BOOT_DRIVE db 0
MSG_REAL_MODE db "You are in 16 bit REAL mode",0
MSG_PROT_MODE db "You landed in 32 bit PROTECTED mode",0
MSG_LOAD_KERNEL db "Loading the kernel now into memory, glhf dont die",0

;padding and magic number
times 510-($-$$) db 0
dw 0xaa55
