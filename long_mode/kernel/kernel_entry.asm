; ensure we jump to kernel entry function - i.e. main
[bits 64]
[extern main]
  call main
  jmp $
