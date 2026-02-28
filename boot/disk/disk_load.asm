; load DH sectors 
disk_load:
  push dx ; store DX on stack so we can recall sectors to be read
  mov ah, 0x02 ; BIOS read sector function
  mov al, dh ; read sector
  mov ch, 0x00 ; read cylinder 0
  mov dh, 0x00; read head 0
  mov cl, 0x02; read read second sector
  int 0x13 ; bios interrupt

  jc disk_error

  pop dx ; restore sectors from stack

  cmp dh, al ; if read sectors does not match the expected sectors
  jne disk_error ; display error message
  ret

disk_error:
  mov bx, DISK_ERROR
  call print_string
  jmp $

; variables 
DISK_ERROR db "Disk read error!", 0
