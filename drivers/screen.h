#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80
// Attribute byte for our default color scheme
#define WHITE_ON_BLACK 0x0f

//Screen device I/O ports
#define REG_SCREEN_CTRL 0x3D4
#define REG_SCREEN_DATA 0x3D5

/* Print a char on the screen at col, row, or at curson position */
void print_char(char character, int col, int row, char attribute_byte) {
  // Create a byte char pointer to the start of video memory
  unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;
  // if attribute_byte is 0, assume default style
  if (!attribute_byte) {
    attribute_byte = WHITE_ON_BLACK
  }

  // Get video memory offset for screen location
  int offset;
  // If col and row are >0, use them for offset
  if (col >= 0 && row >= 0) {
    offset = get_screen_offset(col, row)
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

