; start after bios
[org 0x7c00]
; read sectors

mov [BOOT_DRIVE], dl ;BIOS stores boot drive
; set stack safely out of range
mov bp, 0x8000 
mov sp, bp
; load 2 sectors to 0x0000(ES): 0x9000(BX)
mov bx, 0x9000 
mov dh, 2
mov dl, [BOOT_DRIVE]
call disk_load

;print first loaded word
mov dx, [0x9000]
call print_hex
call print_string 

mov dx, [0x9000 + 512] ; load the next sectors from what we added, should be 0xface
call print_hex
call print_string 
jmp $

%include "print_hex.asm"
%include "print_string.asm"
%include "disk_load.asm"

;Global values
BOOT_DRIVE: db 0

; Padding and magic number.
times 510-($-$$) db 0
dw 0xaa55

; BIOS only loads the first 512 byte sector. 
; so we will add a few more sectors to our code
; by repeating some number
; this will prove we loaded those additional sectors from
; disk (as they wont fit in the first 512 sector)
times 256 dw 0xdada
times 256 dw 0xface

