;
; A boot sector that prints a string using our function.
;
[org 0x7c00] ; Tell the assembler where this code will be loaded

mov bx, HELLO_MSG ; Use BX as a parameter to our function, so
call print_string

mov bx, MSG_REAL_MODE
call print_string

mov bx, GOODBYE_MSG
call print_string

call switch_to_pm 

jmp $ ; Hang
%include "print_string.asm"
%include "gdt.asm"
%include "print_string_pm.asm"
%include "switch_to_pm.asm"

; This is where we arrive after switching to and 
; initializing protected mode
[bits 32]
BEGIN_PM:
  mov ebx, MSG_PROT_MODE
  call print_string_pm
  jmp $ ; hang 

; Data
MSG_REAL_MODE db "Started in 16-bit real mode", 0
MSG_PROT_MODE db "landed in 32-bit protected mode", 0
HELLO_MSG db 'Hello, World!', 0 ; <-- The zero on the end tells our routine
GOODBYE_MSG db 'Goodbye!', 0

; Padding and magic number.
times 510-($-$$) db 0
dw 0xaa55
