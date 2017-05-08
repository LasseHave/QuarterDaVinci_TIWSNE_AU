//Implementation of an image buffer based on a circular buffer.

generic module ImageBufferC(uint16_t bufferSize) {
  provides {
    interface ImageBufferRead;
    interface ImageBufferWrite;
    interface ImageBufferLowLevel;
  }
}
implementation {
  /**
   * Initialization.
   */
  uint8_t _buf[SIZE];
  uint16_t _start = 0;
  uint16_t _end = 0;

  command void ImageBufferWrite.clear() {
    _start = 0;
    _end = 0;
  }

  /**
   * Returns number of available bytes.
   */
  inline uint16_t availableBytes() {
    if (_start <= _end)
      return _end - _start;
    else
      return SIZE - _start + _end;
  }

  command uint16_t ImageBufferRead.available() { return availableBytes(); }

  command error_t ImageBufferRead.read(uint8_t * byte) {
    if (_start == _end) {
      return FAIL;
    } else {
      *byte = _buf[_start++];
      if (_start == SIZE) _start = 0;
      return SUCCESS;
    }
  }

  command error_t ImageBufferRead.readBlock(uint8_t * block, uint16_t len) {
    static uint16_t i;
    if (availableBytes() < len) {
      return FAIL;
    } else {
      for (i = 0; i < len; i++) {
        block[i] = _buf[_start++];
        if (_start == SIZE) _start = 0;
      }
      return SUCCESS;
    }
  }

  /**
   * Returns free space in number of bytes.
   */
  inline uint16_t freeBytes() {
    return SIZE - availableBytes() - 1;
  }

  command uint16_t ImageBufferWrite.free() { return freeBytes(); }

  command error_t ImageBufferWrite.write(uint8_t byte) {
    if (_end + 1 == _start || (_end + 1 == SIZE && _start == 0)) {
      return FAIL;
    } else {
      _buf[_end++] = byte;
      if (_end == SIZE) _end = 0;
      return SUCCESS;
    }
  }

  command error_t ImageBufferWrite.writeBlock(uint8_t * block,
                                                 uint16_t len) {
    static uint16_t i;
    if (free() < len) {
      return FAIL;
    } else {
      for (i = 0; i < len; i++) {
        _buf[_end++] = block[i];
        if (_end == SIZE) _end = 0;
      }
      return SUCCESS;
    }
  }

  command void CircularBufferLowLevel.get(uint8_t * *buffer, uint16_t * *start,
                                          uint16_t * *end, uint16_t * size) {
    *buffer = _buf;
    *start = &_start;
    *end = &_end;
    *size = SIZE;
  }
}
