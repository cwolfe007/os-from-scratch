void some_function(){}

void main() {
  // Create a pointer char 
  // point it at the first cell in memory
  char* video_memory = (char*) 0xb8000;
  // At the address of video_memory, store 'X'
  *video_memory = 'X' ;
}
