interface ImageBufferRead {
  /**
   * Returns number of available bytes.
   */
  command uint16_t availableBytes();

  /**
   * Read single byte from buffer.
   *
   * @param byte     The byte to read into.
   *
   * @return
   *    <li>FAIL => buffer is empty
   *    <li>SUCCESS => buffer not empty and byte was read
   */
  command error_t read(uint8_t * byte);

  /**
   * Read byte block from buffer.
   *
   * @param block     The byte array to read into.
   * @param len       The length of byte array.
   *
   * @return
   *    <li>FAIL => not enough bytes available
   *    <li>SUCCESS => enough bytes and block was read
   */
  command error_t readBlock(uint8_t * block, uint16_t len);
}
