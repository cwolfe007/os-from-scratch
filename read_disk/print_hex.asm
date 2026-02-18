; print hex
[org 0x7c00]
; uncomment the test values below
; mov dx, 0x1fb6
; mov dx, 0x000a
; mov dx, 0xFFFF
mov dx, 0x0009
call print_hex
jmp $

print_hex:
  push dx ; save dx value to the stack
  ;write 0x
  mov cx, 0x0005
  process_hex:
      ; if all bits are shifted right, print hex out
      cmp cx, 1
      je print
      ;move to al to test
      mov ax, dx ;
      ; get the low nibble
      and al, 0x0f  
      mov ah, 0x00 ;set high to 00 to isloate the letter
      
      ;Test to see if number or letter
      test_letter:
        cmp al, 9
        jg convert_letter
        jmp convert_number

      convert_number:
        ; add x30
        add al, 0x30
        ;jump back to process_hex
        jmp print_to
      convert_letter:
         ; add x57
        add al, 0x57
        ;jump back to process_hex
        jmp print_to
      ; "print to HEX_OUT"
      print_to:
        mov bx, HEX_OUT ; get the HEX_OUT address
        add bx, cx ; move the offset to the desired byte
        mov [bx], al; write al to the offset in memory
        sub cx, 1
        ;shift bits right a byte to get the next hex letter
        shr dx, 4
        jmp process_hex

  print:
    mov bx, HEX_OUT
    call print_string
  pop dx ; restore dx to stack
  ret

  HEX_OUT: db '0x0000',0


%include "print_string.asm"
; Padding and magic number.
times 510-($-$$) db 0
dw 0xaa55
