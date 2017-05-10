#ifndef RECEIVER_H
 #define RECEIVER_H
 
 #define printf(fmt,...)

 enum {
 	AM_RECEIVER = 6,
   TIMER_PERIOD_MILLI = 250,
   SIZE_IMAGE = 65536
 };

 typedef nx_struct ImageMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} ImageMsg;

 #endif
