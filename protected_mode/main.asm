;
; A boot sector that prints a string using our function.
;
[org 0x7c00] ; Tell the assembler where this code will be loaded

; Data
HELLO_MSG:
db 'Hello, World!', 0 ; <-- The zero on the end tells our routine
GOODBYE_MSG:
db 'Goodbye!', 0

mov ebx, HELLO_MSG ; Use BX as a parameter to our function, so
call print_string_pm

mov ebx, GOODBYE_MSG
call print_string_pm

jmp $ ; Hang
; Padding and magic number.
%include "vga_example.asm"
times 510-($-$$) db 0
dw 0xaa55
