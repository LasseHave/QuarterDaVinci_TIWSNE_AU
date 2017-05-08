interface CircularBufferWrite {
  /**
   * Clear buffer.
   */
  command void clear();

  /**
   * Returns free space in number of bytes.
   *
   * @return Returns the free space in number of bytes.
   */
  command uint16_t freeBytes();

  /**
   * Write single byte to buffer.
   *
   * @param byte     byte to write
   *
   * @return
   *    <li>FAIL => buffer is full
   *    <li>SUCCESS => byte was written
   */
  command error_t write(uint8_t byte);

  /**
   * Write byte block to buffer.
   *
   * @param block     The byte array to write to buffer.
   * @param len       The length of byte array.
   *
   * @return
   *    <li>FAIL => not enough free space
   *    <li>SUCCESS => enough space and block was written
   */
  command error_t writeBlock(uint8_t * block, uint16_t len);
}
