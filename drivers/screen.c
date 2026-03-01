#include "screen.h"
#include "../kernel/low_level.h"


int get_cursor() {
  int offset;
  // Write byte to the port register
  // Register 14 = high byte of register of cursor offset
  port_byte_out(REG_SCREEN_CTRL, 14);
  // Read byte from the port register
  offset = port_byte_in(REG_SCREEN_DATA) << 8;

  // Register 15 = low byte of register of cursor offset
  port_byte_out(REG_SCREEN_CTRL, 15);
  offset += port_byte_in(REG_SCREEN_DATA);
  // Since the cursor offset reported by the VGA 
  // is the hardware number of the characters
  // we multiply by two to convert it to 
  // a character cell offset
  return offset * 2;
}

int get_screen_offset(int target_col, int target_row){
  int row_pos;
  int col_pos;
  int char_byte_alloc_pos;
  // Find the row
  row_pos = target_row * MAX_COLS;
  // find column in the row 
  col_pos = row_pos + target_col;
  // The character is chat byte and attribute_byte
  char_byte_alloc_pos = col_pos * 2;
  return char_byte_alloc_pos;
}

void set_cursor(int offset){
  offset /= 2;
  char high_offset = offset << 8;
  char low_offset = offset >> 8;
  // Set the high byte of the cursor offset
  port_byte_out(REG_SCREEN_CTRL, 14);
  port_byte_out(REG_SCREEN_DATA, high_offset); 
  // Set the low byte of the cursor offset
  port_byte_out(REG_SCREEN_CTRL, 15);
  port_byte_out(REG_SCREEN_DATA, low_offset); 
}

int handle_scrolling(int offset){

}

/* Print a char on the screen at col, row, or at curson position */
void print_char(char character, int col, int row, char attribute_byte) {
  // Create a byte char pointer to the start of video memory
  unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;
  // if attribute_byte is 0, assume default style
  if (!attribute_byte) {
    attribute_byte = WHITE_ON_BLACK;
  }

  // Get video memory offset for screen location
  int offset;
  // If col and row are >0, use them for offset
  if (col >= 0 && row >= 0) {
    offset = get_screen_offset(col, row);
  } else {
    // otherwise get cursor position
   offset = get_cursor(); 
  }

  // if a newline character is detected, set the offset to the end of 
  // the current row, this way we move down to the next row at the first column 
  if (character == '\n') {
    int rows = offset / (2*MAX_COLS);
    offset = get_screen_offset(79, rows);
  } else {
    // otherwise, write the character and its attribute_byte to 
    // video memory at our calculated offset
    vidmem[offset] = character;
    vidmem[offset+1] = attribute_byte;
  }

  //Update the offset to the "next" character cell (next = character and attribute_byte)
  offset += 2;
  // Make scrolling adjustment, for when we reach bottom of the screen
  offset = handle_scrolling(offset);
  // update the cursor position
  set_cursor(offset);
}
