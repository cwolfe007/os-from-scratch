; simple stack example

mov ah,0x0e ; teletype mode bios

mov bp, 0x8000 ; move stack base above BIOS so we dont overwrite bios
mov sp, bp 

push 'A'
push 'B'
push 'C'

pop bx ; we can only pop 16 bits, pop to bx register

mov al, bl ; copy bl to al (8bit char)
int 0x10; print al

pop bx; move to the next value on the stack
mov al, bl; copy bl to al next char
int 0x10; print

mov al, [0x7ffe]
int 0x10; print
jmp $

times 510-($-$$) db 0
dw 0xaa55
