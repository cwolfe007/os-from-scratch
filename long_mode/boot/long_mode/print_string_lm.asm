[bits 64]
;Define some constants
VIDEO_MEMORY equ 0xb8000 ; VGA
WHITE_ON_BLACK equ 0x0f ; VGA setting
;VIDEO_MEMORY equ 0x3f8 ; Serial

;print null terminated string at EDX
print_string_lm:
  pushaq
  mov rdx, VIDEO_MEMORY

  .print_string_lm_loop:
    mov al, [rbx]
    mov ah, WHITE_ON_BLACK ; VGA setting
    
    ; if we hit the null terminator, go to done
    cmp al, 0
    je .print_string_lm_done

    mov [rdx], ax ;Store char

    add rbx, 1 ; increment EBX to the next char in string
    add rdx, 2 ; move to the next character cell in vid memory
    
    jmp .print_string_lm_loop

.print_string_lm_done:
  popaq
  ret ; return from function

%macro pushaq 0
  push rdx
  push rax
  push rbx
  push rcx
%endmacro

%macro popaq 0
  pop rcx
  pop rbx
  pop rax
  pop rdx
%endmacro
