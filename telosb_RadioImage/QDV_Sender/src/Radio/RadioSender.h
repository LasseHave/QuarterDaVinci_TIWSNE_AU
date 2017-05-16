#ifndef RECEIVER_H
 #define RECEIVER_H
 #include <message.h> //to get TOSH_DATA_LENGTH NOTE: Overwritten in makefile!

 enum {
 	AM_SENDER = 6,
 	AM_RECEIVER = 6,
   TIMER_PERIOD_MILLI = 250,
   DATA_SIZE = (TOSH_DATA_LENGTH - 4),
   PICTURE_PART_NR = 8,
   SIZE_IMAGE = 65536, // 256 x 256 image,
   PICTURE_PART_SIZE = SIZE_IMAGE/PICTURE_PART_NR
 };

 typedef nx_struct ImageMsg {
  nx_uint16_t nodeid;
  nx_uint16_t total_package_nr_in_part;
  nx_uint8_t data[DATA_SIZE];
} ImageMsg;

typedef nx_struct AckMsg {
  nx_uint16_t ack;
} AckMsg;

 #endif
