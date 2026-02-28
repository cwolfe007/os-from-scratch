; simple boot to print message from bios

mov ah, 0x0e ; scrolling teletype  BIOS routine

mov al, 'H'
int 0x10 ; interrupt
mov al, 'e'
int 0x10 ; interrupt
mov al, 'l'
int 0x10 ; interrupt
mov al, 'l'
int 0x10 ; interrupt
mov al, 'o'
int 0x10 ; interrupt

jmp $ ; jump to current address (i.e. loop forever)

;move to the end of the 512 sector and add the magic number

times 510-($-$$) db 0; write 0s for 510 bytes

dw 0xaa55


