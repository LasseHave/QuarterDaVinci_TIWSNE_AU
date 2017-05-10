#ifndef RADIO_INFO_H
#define RADIO_INFO_H


#define PAYLOADSIZE 50


typedef nx_struct radio_packet_msg_t {
	nx_uint16_t TotalSize;
	nx_uint16_t ID;
	nx_uint8_t len;
	nx_uint8_t Data[PAYLOADSIZE];
} radio_packet_msg_t;


#endif /* RADIO_INFO_H */