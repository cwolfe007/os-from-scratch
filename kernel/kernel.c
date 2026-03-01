#include "low_level.h"
#include "../drivers/screen.h"

void main() {
  // Create a pointer char 
  // point it at the first cell in memory
  char* video_memory = (char*) 0xb8000;
  // At the address of video_memory, store 'X'
  // *video_memory = 'X' ;
  print_char('E',1,0,0);
}
