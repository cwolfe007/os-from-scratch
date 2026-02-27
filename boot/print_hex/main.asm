
[org 0x7c00]
; uncomment the test values below
; mov dx, 0x1fb6
; mov dx, 0x000a
; mov dx, 0xFFFF
mov dx, 0x0009
call print_hex
call print_string

jmp $
%include "print_hex.asm"
%include "print_string.asm"
times 510-($-$$) db 0
dw 0xaa55
