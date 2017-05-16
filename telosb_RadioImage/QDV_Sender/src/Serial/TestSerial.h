#ifndef TEST_SERIAL_H
#define TEST_SERIAL_H

typedef nx_struct chunk_msg {
  nx_uint16_t chunkNum;
  nx_uint8_t chunk[64];
} chunk_msg_t;

typedef nx_struct status_msg {
  nx_uint16_t chunkNum;
  nx_uint8_t status;
} status_msg_t;

enum {
  AM_CHUNK_MSG_T = 0x8A,
  AM_STATUS_MSG_T = 0x8B,
};

enum {
	TRANSFER_TO_TELOS = 1,
	TRANSFER_OK = 2,
	TRANSFER_FAIL = 3,
	TRANSFER_READY = 4,
	TRANSFER_FROM_TELOS = 5,
	TRANSFER_DONE = 6,
};

#endif
