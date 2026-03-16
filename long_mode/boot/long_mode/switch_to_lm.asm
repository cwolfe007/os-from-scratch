[bits 16]
; switch to long mode
switch_to_lm:
  cli  ; We mst switch interrupts until we have set up 
       ; the long mode interrupt vector
       ; this prevents interrupts causing problems while switching from real to long modes

  lgdt [gdt_descriptor] ; load global descriptor table

  ; switch to long mode and enable protected mode
  EFER_LM_ENABLE equ 1 << 8 ; EFER is Extended feature regiser
  mov ecx, 0xC0000080 ; set address for reading MSR
  rdmsr ; read manufacture specific regiser
  or eax, EFER_LM_ENABLE
  wrmsr
  ; set up protected mode
  CRO_PM_ENABLE equ 1 << 31
  mov eax, cr0 
  or eax, CRO_PM_ENABLE 
  mov cr0, eax

  jmp CODE_SEG:init_lm; Make far jump to new segment to 
                      ; 32-bit code. Forces CPU to  
                      ; Flush pipeline of pre-fetched and real mode decoded 
                      ;
                      ; instructions. Flushing prvents unwanted problems
[bits 64]
; Initialise registers and the stack once in PM
init_lm:
  ; now in PM, load new segments 
  mov ax, DATA_SEG
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  mov rbp, 0x9000 ; Update our stack position so it is right
  mov rsp, rbp    ; at the top of free space

  call BEGIN_LM

