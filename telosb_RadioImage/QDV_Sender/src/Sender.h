#ifndef SENDER_H
#define SENDER_H

#define PAYLOADSIZE 50


 enum {
 	AM_SENDER = 6,
   TIMER_PERIOD_MILLI = 250,
   SIZE_IMAGE = 65536
 };

 typedef nx_struct ImageMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} ImageMsg;



typedef nx_struct radio_packet_msg_t {
	nx_uint16_t TotalSize;
	nx_uint16_t ID;
	nx_uint8_t len;
	nx_uint8_t Data[PAYLOADSIZE];
} radio_packet_msg_t;

 #endif
