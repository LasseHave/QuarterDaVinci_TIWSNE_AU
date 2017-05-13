#ifndef RECEIVER_H
 #define RECEIVER_H
 #include <message.h> //to get TOSH_DATA_LENGTH

 enum {
 	AM_SENDER = 6,
   TIMER_PERIOD_MILLI = 250,
   SIZE_IMAGE = 65536,
   MESSAGE_SIZE = 28,
   IMAGE_SIZE = 26
 };

 typedef nx_struct ImageMsg {
  nx_uint16_t nodeid;
  nx_uint8_t data[TOSH_DATA_LENGTH - 2];
} ImageMsg;

 #endif
