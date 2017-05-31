#ifndef TEST_SERIAL_H
#define TEST_SERIAL_H

typedef nx_struct DataMsg {
  nx_uint16_t id;
  nx_uint8_t data[64];
} DataMsg;

typedef nx_struct StatusMsg {
  nx_uint16_t id;
  nx_uint8_t status;
} StatusMsg;

enum {
  AM_CHUNK_MSG_T = 0x8A,
  AM_STATUS_MSG_T = 0x8B,
};

enum {
	RECEIVING = 1,
	OK = 2,
	FAILED = 3,
	READY = 4,
	SENDING = 5,
	DONE = 6,
};

#endif