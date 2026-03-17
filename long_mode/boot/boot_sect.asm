; Kernel Boot Loader
[org 0x7c00]

; If this bit and be flipped the CPUID instruction is available
EFLAGS equ 1 << 21  

; ; Checks if CPUID is supported
; checkCPUID:
;   pushfd
;   pushd
;   pop eax
;   mov ecx, eax; save original  value for later
;   xor eax, EFLAGS_ID
;
;   ;store the eflags and retrieve it later to validate if bit was successfully flipped
;   push eax
;   popfd
;   pushfd
;   pop eax
;
;   ; if bit was flipped then ecx != eax
;   xor eax, ecx
;   jnz .supported
;   .notSupported
;      mov ax, 0
;      ret
;   .supported 
;      mov ax, 1
;      ret

KERNEL_OFFSET equ 0x1000 ; This is the memory offset which we laod our kernel
  mov [BOOT_DRIVE], dl ; Save disk loader contents to DL

  ; set up the stack
  mov bp, 0x9000 ; save base pointer to x9000
  mov sp, bp ; set stack point to base pointer 

  mov bx, MSG_REAL_MODE ; 
  call print_string

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
  mov bx, MSG_LOAD_KERNEL
  call print_string

  ;Prepare sectors for disk load routines
  
  mov bx, KERNEL_OFFSET
  mov dh, 9 ; Load the first 9 sectors (1-9 seem valid) (excluding bootdrive)
  mov dl, [BOOT_DRIVE] ; Load the boot drive sector from disk where our kernel lives
  call disk_load
  ret

; Start to switch to protected_mode
[bits 64]
; Area to land after swithcing to protected_mode

BEGIN_LM:
  mov BYTE [0xb8000], 0x41 ; test to see if wew in BEGIN_LM 
  mov rbx, MSG_LONG_MODE ;print message indicating we landed in protected_mode as epxected 
  call print_string_lm

  call KERNEL_OFFSET ; Jump to where we *think* the kernel is, YOLO
  ; call checkCPUID 

  ; ; note because we are entering long mode, we will skip paging in protected_mode(32 bit mode)
  ; ;
  ; ; 64 bit page table is double to size of the 32 bit table
  ; ; For this example we will skip the higher half kernel for now
  ; PML4T_ADDR equ 0x1000; We will map the first 2MiB of memory 
  ; SIZE_OF_PAGE_TABLE equ 4096
  ;
  ; mov edi, PML4T_ADDR
  ; mov cr3, edi
  ; xor eax, eax
  ; mov ecx, SIZE_OF_PAGE_TABLE
  ; rep stosd ; write 4 * SIZE_OF_PAGE_TABLE bytes, which is expected to be enough space
  ;
  ; mov edi, cr3 ; reset di back to beggining of page table

  jmp $

; Global vars
BOOT_DRIVE db 0
MSG_REAL_MODE db "16 bit REAL mode - ",0
MSG_LONG_MODE db "64 bit long mode - ",0
MSG_LOAD_KERNEL db "Loading the kernel now",0
MSG_TEST db "lm",0

times 510-($-$$) db 0
dw 0xaa55
