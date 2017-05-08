/**
 * Compression of data.
 */
interface Compression {
  /**
   * Starts compression process.
   *
   * @return
   *    <li>EBUSY => the compression is already running
   *    <li>SUCCESS => the compression has been started successfully
   */
  command error_t compress();

  /**
   * Signals the end of the compression.
   *
   * @param error   SUCCESS => the compression was successful.
   */
  event void compressDone(error_t error);
}
