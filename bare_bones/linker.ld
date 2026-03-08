/* Tell the bootloader where to look */
ENTRY(_start)

/* Tell the linker where to look for the various sections of object files to be put into the kernel image */

SECTIONS
{
  /* With UEFI, start 2M as the start of the offset */
  . = 2M;

  .test BLOCK(4K) : ALIGN(4K)
  {
     *(.multiboot)
     *(.text)
  }
  /* read only data */
  .rodata BLOCK(4K) : ALIGN(4K)
  {
    *(.rodata)
  }
  .data BLOCK(4K) : ALIGN(4K)
  {
     *(.data)
  }

  .bss BLOCK(4K) : ALIGN(4K)
  {
    *(COMMON)
    *(.bss)
  }
}
