# Set up multiboot
.set ALIGN, 1<<0 # align loaded modules on page boundaries
.set MEMINFO, 1<<1 # provide memory map
.set FLAGS, ALIGN | MEMINFO # multiboot flag field
.set MAGIC, 0x1BADB002 # magic number for multiboot
.set CHECKSUM, -(MAGIC + FLAGS) # CHECKSUM of the above to prove multiboot

# Declare multiboot header
.section .multiboot.data, "aw"
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Allocation of intial stack
.section .bootstrap_stack, "aw", @nobits
stack_bottom:
.skip 16384 #16KiB
stack_top:

#Preallocate pages, but we do not yet know the available memory addresses
# bootloader may have taken addresses, so we let the bootloader know that
# addresses to avoid
.section .bss, "aw", @nobits
   .align 4096
boot_page_directory:
  .skip 4096
boot_page_table1:
  .skip 4096

#Kernel entry point
.section .multiboot.text, "a"
.global _start
.type _start, @function
_start:
  # Physical address of boot_page_table1
  movl $(boot_page_table1 - 0xC0000000), %edi
# First address (in the new space) is 0
  movl $0, %esi
#Map 1023 pages, the 1024th is VGA
  movl $1023, %ecx
1:
  # Only map the kernel
  cmpl $_kernel_start, %esi
  jl 2f # jmp to 2
  cmpl $(_kernel_end - 0xC0000000), %esi
  jge 3f # jmp to 3

  # map pyshical address as "present" and "writable"
  # Note that this maps to .text and .rodata as writable
  # We must ensure security and map them as non-writable
  movl %esi, %edx # move the index to edx
  orl $0x003, %edx # Set the present positional(0) and writable positional(1) bits, i.e. 0011b 
  movl %edx, (%edi) # store edx to edi
2:
 # Store a page (4096 bytes)
 addl $4096, %esi
# entry in boot table is 4 bytes
 addl $4, %edi
#loop to next entry
 loop 1b # go back to section 1
3:
  # Map VGA memory to xC03FF000 as "present" and "writable"
  movl $(0x000B8000 | 0x003), boot_page_table1 - 0xC0000000 + 1023 * 4

  # Map the page table to both virtual addresses 0x0000000 and 0xC0000000

  # The page table is used at both page directory entry 0 
  # we need this since when we start paging, the assumed positon 0 in virtual memory not be known by th cpu on how stack_top
  # map for pyshical memory 
  #(virtualy from 0x0 -> 0x3FFFFF, this identity mapping to the kernel) 
  movl $(boot_page_table1 - 0xC0000000 + 0x003), boot_page_directory - 0xC0000000 + 0

  # and the page directory entry 768 (0xC0000000 -> xC03FFFFF) (mapping to the higher half)
  # 768 is from xC0000000 / 4MiB (the page directory entry) 
  # this is effectively saying we want to start the kernel at position 768 and leave 767 directory entries for user space
  movl $(boot_page_table1 - 0xC0000000 + 0x003), boot_page_directory - 0xC0000000 + 768 * 4
  
  # Set cr3 to the address of the boot_page directory
  movl $(boot_page_directory - 0xC0000000), %ecx
  movl %ecx, %cr3

 # enable paging and write-protect bit
 movl %cr0, %ecx
 #bits 10000... (ie 0x80000...) is Paging enabled
 #bits 0000 0000 0000 0001 ... (ie 0x00010000) is write-protect enabled
 orl $0x80010000, %ecx
 movl %ecx, %cr0

 #jump to hight half of the memory with absolute jmp
 lea 4f, %ecx
 jmp *%ecx

.section .text

4:
  # At this point, paging is fully set up and enabled
  movl $0, boot_page_directory + 0

  # Reload crc3 to force the flush of the translation lookaside buffer
  movl %cr3, %ecx
  movl %ecx, %cr3

  #set up the stack
  mov $stack_top, %esp

  call kernel_main

  cli #disable interuptes

# Loop forever
1: hlt
    jmp 1b # jump back to 1











