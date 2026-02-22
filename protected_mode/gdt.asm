; GDT
gdt_start :

gdt_null:
  dd 0x0 ; double word - 4bytes
  dd 0x0 ; double word - 4bytes

gdt_code : ; segment descriptor code
  dw 0xffff ; base 0x0 -> 0xffff limit
  dw 0x0 ; Base bits 0 -15
  db 0x0 ; Base bits 16 - 23
  db 10011010b ; 1st flags,  present 1 - priviledge 00 - descriptor type 1 -> 1001b
              ; type flags, code 1 - conforming 0 - readable 1 - accessed 0 -> 1010b
  db 11001111b ; 2nd flags, granularity  1  - 32bit default 1 - 64bit segment 0 -  AVL 1 -> 1100b
              ; limit - 1111b
  db 0x0 ; Base (bits 24-31)

gdt_data: ; segment descriptor data
  dw 0xffff ; limit bits 0 -15
  dw 0x0 ; base bits 0 - 15
  dw 0x0 ; base bits 16 - 23
  db 10010010b ; 1st flags and type flags
  db 11001111b ; 2nd flags and limit bits
  db 0x0 ; base bits 24 -31

gdt_end:
  ; add a label at the end for the assembler to calculate teh size of the GDT for the GDT descriptor

gdt_descriptor:
; GDT descriptor
  dw gdt_end - gdt_start - 1 
  ; size of our gdt, always less by one of the true size 
  dd gdt_start

; Define constants for GDT descriptor off sets
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
