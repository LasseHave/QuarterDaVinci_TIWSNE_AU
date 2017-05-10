#include "Sender.h"
#include "Timer.h"


module RadioSenderC{
	provides interface RadioSenderI; 
	uses interface AMSend;
	uses interface SplitControl as AMControl;
    uses interface Packet;
}

implementation{
	bool isSending = FALSE; 
	
	uint16_t CurrentPacketCount;
	uint16_t TotalCount;
	
	message_t packet;
	uint8_t *dataPtr;
	uint16_t dataPtrLength;
	

	void CreatePacketsCount(uint16_t length)
	{
		TotalCount = (length/PAYLOADSIZE) + (length%PAYLOADSIZE != 0 ? 1 : 0); 
		CurrentPacketCount = 0; 
	}
	
	
	
	void CreatePacketsPacket(uint8_t *ptr,uint16_t length, uint16_t id)
	{
		int i = 0; 
		radio_packet_msg_t* payload = (radio_packet_msg_t*)call Packet.getPayload(&packet, sizeof(radio_packet_msg_t));
		payload->ID = id; 
		payload->TotalSize = length;
		payload->len = (length/PAYLOADSIZE) >= id ? PAYLOADSIZE : (length%PAYLOADSIZE);
		memcpy(payload->Data, &ptr[(id-1)*PAYLOADSIZE],payload->len);
		
	}
	
	bool SendNextPacket()
	{
		uint16_t id = ++CurrentPacketCount;
		
		if(id > TotalCount)
		{
			return FALSE; 
		}
		
		CreatePacketsPacket(dataPtr,dataPtrLength, id);
		
		
		if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_packet_msg_t)) != SUCCESS) 
		{
			return FALSE; 
        }
        
        return TRUE; 
	}
	
	
	command error_t RadioSenderI.Send(uint8_t *ptr, uint16_t length){
		if(isSending == FALSE)
		{
			dataPtr = ptr;
			dataPtrLength = length;
			CreatePacketsCount(length);
			if(call AMControl.start() != SUCCESS)
			{
				return FAIL; 
			}
			isSending = TRUE;
								
			return SUCCESS;	
		}
		return FAIL; 
	}

	event void AMSend.sendDone(message_t *msg, error_t error){
		
		if (&packet == msg) {
			if(SendNextPacket() == FALSE)
			{
				call AMControl.stop();
			}
    	}
	}

	event void AMControl.startDone(error_t error){
		SendNextPacket();
	}

	event void AMControl.stopDone(error_t error){
		isSending = FALSE; 
		signal RadioSenderI.SendDone();
	}
}