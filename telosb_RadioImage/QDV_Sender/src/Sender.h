#ifndef RECEIVER_H
 #define RECEIVER_H

 enum {
 	AM_RECEIVER_H = 6,
   TIMER_PERIOD_MILLI = 250
 };

 typedef nx_struct ReceiverMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} ReceiverMsg;

 #endif
