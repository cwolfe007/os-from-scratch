[bits 32]
;Define some constants
VIDEO_MEMORY equ 0xb8000 ; VGA
WHITE_ON_BLACK equ 0x0f ; VGA setting
; VIDEO_MEMORY equ 0x3f8 ; Serial

;print null terminated string at EDX
print_string_pm:
  pusha
  mov edx, VIDEO_MEMORY

print_string_pm_loop:
  mov al, [ebx]
  mov ah, WHITE_ON_BLACK ; VGA setting
  
  ; if we hit the null terminator, go to done
  cmp al, 0
  je print_string_pm_done

  mov [edx], ax ;Store char

  add ebx, 1 ; increment EBX to the next char in string
  add edx, 2 ; move to the next character cell in vid memory
  
  jmp print_string_pm_loop

print_string_pm_done :
  popa
  ret ; return from function
