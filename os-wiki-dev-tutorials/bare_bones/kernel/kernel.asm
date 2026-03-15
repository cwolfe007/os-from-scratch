BITS 32

VGA_WIDTH equ 80 
VGA_HEIGHT equ 25

VGA_COLOR_BLACK equ 0
VGA_COLOR_BLUE equ 1
VGA_COLOR_GREEN equ 2
VGA_COLOR_CYAN equ 3
VGA_COLOR_RED equ 4
VGA_COLOR_MAGENTA equ 5
VGA_COLOR_BROWN equ 6
VGA_COLOR_LIGHT_GREY equ 7
VGA_COLOR_DARK_GREY equ 8
VGA_COLOR_LIGHT_BLUE equ 9
VGA_COLOR_LIGHT_GREEN equ 10
VGA_COLOR_LIGHT_CYAN equ 11
VGA_COLOR_LIGHT_RED equ 12
VGA_COLOR_LIGHT_MAGENTA equ 13
VGA_COLOR_LIGHT_BROWN equ 14
VGA_COLOR_WHITE equ 15

global kernel_main
kernel_main:
  mov dh, VGA_COLOR_LIGHT_GREY
  mov dl, VGA_COLOR_BLACK
  call terminal_set_color 
  mov esi, hello_string
  jmp terminal_write_string

terminal_set_color:
  shl dl, 4
  or dl, dh
  ret

; get the offset from video memory
terminal_getidx:
  push ax
  shl dh, 1 ; shift left 1 bit = multiply by 2, accounts for char and attribute bytes

  mov al, VGA_WIDTH
  mul dl ; dl * al, aka times a "row"
  mov dl, al
  shl dl, 1
  add dl, dh
  mov dh, 0
  pop ax
  ret

terminal_put_entry_at:
  pusha
  call  terminal_getidx
  mov ebx, edx
  mov dl, [terminal_color]
  ;xB8000 is the VGA memory address
  mov byte [0xB8000 + ebx], al ; write char
  mov byte [0xB8001 + ebx], dl ; write attribute type
  popa
  ret

terminal_put_char:
  pusha

  mov dx, [terminal_cursor_pos]
  call terminal_put_entry_at

  inc dh
  cmp dh, VGA_WIDTH ; if the offset is at the end of the row
  jne .cursor_moved
  
  mov dh, 0
  inc dl

  cmp dl, VGA_HEIGHT ; if the offet reaches the end of the screen
  jne .cursor_moved
  mov dl, 0 ; reset 

  popa
  ret

.cursor_moved:
  ; store new cursor position
  mov [terminal_cursor_pos], dx
  ret


terminal_write:
    pusha
.loopy:
  mov al, [esi]
  call terminal_put_char
  dec cx ; decrement the remaining str length
  cmp cx, 0 ; if we hit the length of the string, end
  jmp .done
  inc esi
.done:
  popa
  ret

; IN = ESI: zero delimited strnig location
; OUT = ECX: length of string
terminal_strlen:
  push eax ; save stack
  push esi ; save stack index
  mov ecx, 0 ; reset counter
; Increase counter to store str length
.loopy:
  ; proceed to next letter
  mov al, [esi]
  ;if null terminator is detected end
  cmp al, 0
  je .done
  ; move to next byte offset to get next char
  inc esi 
  ; increase counter for str length
  inc ecx
  jmp .loopy

.done:
  pop esi
  pop eax
  ret


terminal_write_string:
  pusha ;save stack
  call terminal_strlen
  call terminal_write
  popa
  ret

; Global Vars
hello_string db "hello, kernel world!", 0xA, 0
terminal_color db 0

terminal_cursor_pos:
terminal_col db 0
terminal_row db 0
