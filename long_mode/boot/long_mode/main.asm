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

call switch_to_lm 

jmp $ ; Hang
%include "print_string.asm"
%include "gdt.asm"
%include "print_string_lm.asm"
%include "switch_to_lm.asm"

; This is where we arrive after switching to and 
; initializing protected mode
[bits 64]
BEGIN_LM:
  mov ebx, MSG_PROT_MODE
  call print_string_pm
  jmp $ ; hang 

; Data
MSG_REAL_MODE db "Started in 16-bit real mode", 0
MSG_PROT_MODE db "landed in 64-bit long mode", 0
HELLO_MSG db 'Hello, World!', 0 ; <-- The zero on the end tells our routine
GOODBYE_MSG db 'Goodbye!', 0

; Padding and magic number.
times 510-($-$$) db 0
dw 0xaa55
