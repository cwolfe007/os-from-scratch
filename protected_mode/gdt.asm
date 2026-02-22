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
  db 0x0 ; Base (bits 24-31)
