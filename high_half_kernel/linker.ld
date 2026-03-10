ENTRY (_start)

SECTIONS
{
  . = 0x00100000;
  /* Kernel starts at 3Gib + 1Mib offset (leaving 1Gib for kernel page directory entries)
   * which is actually mapped to 1MB in the physical address space
   */

  _kernel_start = .;
  .mulitboot.data : {
    *(.multiboot.data)
  }
  .mulitboot.text : {
    *(.multiboot.text)
  }

  . += 0xC0000000;
  /* Add a symbol that indicates the start addess of the kernel */
  .text ALIGN (4K) : AT (ADDR (.text) - 0xC0000000)
  {
    *(.text)
  }
  .rodata ALIGN (4K) : AT (ADDR (.rodata) - 0xC0000000)
  {
    *(.rodata)
}
  .data ALIGN (4K) : AT (ADDR (.data) - 0xC0000000)
  {
    *(.data)
}
  .bss ALIGN (4K) : AT (ADDR (.bss) - 0xC0000000)
  {
    *(COMMON)
    *(.bss)
    *(.bootstrap_stack)
}
/* Add symbol to indicate the end of address of the kernel
 */
 _kernel_end = .;
}
