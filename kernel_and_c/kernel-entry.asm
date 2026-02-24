; ensure we jump to kernel entry function - i.e. main
[bits 32]
[extern main]
  call main
  jmp $
