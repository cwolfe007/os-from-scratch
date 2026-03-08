; simple boot program to demonstrate addressing
[org 0x7c00]
mov ah, 0x0e ; teletype bios

  ;first attempt
;  mov al, the_secret
;  int 0x10 ;print x?
  
  ;second attempt
  mov al, [the_secret] 
  int 0x10 ;print x?

  ;third attempt
;  mov bx, the_secret
;  add bx, 0x7c00
;  mov al, [bx]
;  int 0x10
 
  ;fourth attempt
;  mov al, [0x7c1e]
;  int 0x10

  jmp $

the_secret:
  db "X"

times 510-($-$$) db 0
dw 0xaa55
