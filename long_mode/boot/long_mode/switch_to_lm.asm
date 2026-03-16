[bits 16]
; switch to long mode
switch_to_lm:
  cli  ; We mst switch interrupts until we have set up 
       ; the long mode interrupt vector
       ; this prevents interrupts causing problems while switching from real to long modes

  lgdt [gdt_descriptor] ; load global descriptor table


  
  ; Set up PLMT4 tables (and the PDPT -> PD -> PT)
  ; I need space for 4096 4KiB entries (or 16KiB)
  ; My stacks bottom is at x9000
  ; I need 2 ^ 16 spaces down (i.e. x4000) for the page data structures
  ; We must also avoid the VGA memory (xa0000 -> xb8000 + (80*25))
  ; The kernel will be loaded at x1000
  PLMT4_ADDR equ 0x4000
  PDPT_ADDR equ 0x5000
  PDT_ADDR equ 0x6000
  PD_ADDR equ 0x7000
  PT_ADDR equ 0x8000
  PAGE_TABLE_SIZE equ 4096 ; bytes
  ; set up the table and zero out the memory
  mov edi, PLMT4_ADDR
  mov cr3, edi ; cr3 is where the cpu looks for page table addresses
  ; Set up the stosd instruction, it will automatically increment by 4, and write the values of eax to memory
  ; the rep will read ecx and repeat as many times is in ecx
  ; we will zero out the memory for our page table, thus eax = 0
  xor eax, eax ; ensure values are zeroed out
  mov ecx, 5120 ; 4096 bytes in 5 tables / 4 bytes per repeat in stosd
  rep stosd

  ; Now we link the first entries of each table

  ; The page table only uses certain parts of the address
  PT_ADDR_MASK equ 0xffffffffff000
  PT_PRESENT equ 1 ; mask the entries as in use
  PT_READABLE equ 2 ; marks entry as read/write

  mov edi, PLMT4_ADDR; move edi back to where PLMT4_ADDR table starts
  mov DWORD [edi], PDPT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

  mov edi, PDPT_ADDR; move edi back to where PDPT_ADDR table starts
  mov DWORD [edi], PDT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

  mov edi, PDT_ADDR
  mov DWORD [edi], PD_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

  mov edi, PD_ADDR
  mov DWORD [edi], PT_ADDR & PT_ADDR_MASK | PT_PRESENT | PT_READABLE

  ENTRIES_PER_PT equ 512 ; half the size of 32 bit number of entries since the entry is double the size
  PT_ENTRY_SIZE equ 8 ; 8 byts
  PAGE_SIZE equ 0x1000 ; 4096 bytes 
 
  mov edi, PT_ADDR
  mov ebx, PT_PRESENT | PT_READABLE
  mov ecx, ENTRIES_PER_PT

  .set_entry: ; decrements ecx, exits when zero
    mov DWORD [edi], ebx
    add ebx, PAGE_SIZE
    add edi, PT_ENTRY_SIZE
    loop .set_entry

  ; switch to long mode and enable protected mode
  ;set up long mode
  EFER_LM_ENABLE equ 1 << 8 ; EFER is Extended feature regiser
  mov ecx, 0xC0000080 ; set address for reading MSR
  rdmsr ; read manufacture specific regiser
  or eax, EFER_LM_ENABLE
  wrmsr
  ; set up protected mode
  CRO_PM_ENABLE equ 1 << 0 ; enable protected mode
  CRO_PG_ENABLE equ 1 << 31 ; enable paging mode
  mov eax, cr0 
  or eax, CRO_PM_ENABLE | CRO_PG_ENABLE 
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

