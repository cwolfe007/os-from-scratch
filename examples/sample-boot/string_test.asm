; simple boot program to demonstrate addressing
[org 0x7c00]
mov ah, 0x0e ; teletype bios


  mov al, [the_secret] 
  int 0x10 ;print x?
 
  jmp $

the_secret:
  db "booting OS", 0

times 510-($-$$) db 0
dw 0xaa55
