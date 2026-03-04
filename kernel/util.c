// byte data transfer driver

// Get data from memory (in to the program)
unsigned char port_byte_in(unsigned short port) {
// C wrapper to read byte from port
  // Put AL register in variable result
  // "d" (port), means load EDX with port
  unsigned char result;
  __asm__("in %%dx, %%al" : "=a" (result): "d" (port));
  return result; 
}

// Send data to memory (out from the program)
void port_byte_out(unsigned short port, unsigned char data) {
  // "a" (data) = load EAX with data
  // "d" (port) = load EDX with port
  __asm__("out %%al, %%dx" : :"a" (data), "d" (port));
}

// word data transfer driver
unsigned short port_word_in(unsigned short port) {
  unsigned short result;
  __asm__("in %%dx, %%ax": "=a" (result) : "d" (port));
  return result;
}


unsigned short port_word_out(unsigned short port, unsigned short data) {
  __asm__("out %%ax, %%dx" : :"a" (data), "d" (port));
}

void memory_copy(char* src, char* dest, int num_bytes) {
   for (int i=0; i < num_bytes; i++){
    dest[i] = src[i];
  }
}
