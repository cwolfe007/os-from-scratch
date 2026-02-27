[bits 16]
; switch to protected mode
switch_to_pm:
  cli  ; We mst switch interrupts until we have set up 
       ; the protected mode interrupt vector
       ; this prevents interrupts causing problems while switching from real to protected modes

  lgdt [gdt_descriptor] ; load global descriptor table

  ; switch to protected mode
  mov eax, cr0 
  or eax, 0x1 
  mov cr0, eax

  jmp CODE_SEG:init_pm ;Make far jump to new segment to 
                      ; 32-bit code. Forces CPU to  
                      ; Flush pipeline of pre-fetched and real mode decoded 
                      ;
                      ; instructions. Flushing prvents unwanted problems
[bits 32]
; Initialise registers and the stack once in PM
init_pm:
  ; now in PM, load new segments 
  mov ax, DATA_SEG
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  mov ebp, 0x9000 ; Update our stack position so it is right
  mov esp, ebp    ; at the top of free space

  call BEGIN_PM

