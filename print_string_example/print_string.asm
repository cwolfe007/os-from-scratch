print_string:
  pusha ;save the stack
  mov ah, 0x0e

comp_block:
  cmp byte [bx], 0 ; if the current byte is  null
  je ret_block ; then return
  jmp print_block ;else - print the next char

print_block:
  mov al, [bx]; grab char
  int 0x10 ;print
  add bx, 0x01 ;move the the next byte
  jmp comp_block ;jump back to the comparison block (comp_block)
  
ret_block:
  popa; restore the stack
  ret; return to pointer in main
