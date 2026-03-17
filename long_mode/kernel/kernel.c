#include "../drivers/screen.h"

void main() {
  char* message;
  message = "Hello\nWorld";
  clear_screen(); 
  print(message);
}
