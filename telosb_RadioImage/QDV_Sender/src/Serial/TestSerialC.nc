#include "Timer.h"
#include "TestSerial.h"
#include "Flash.h"
#include <UserButton.h>
#include "printf.h"

module TestSerialC {
	provides interface TestSerialI;
	
	uses interface SplitControl as Control;
	uses interface Receive as ReceiveData;
	uses interface AMSend as SendData;
	uses interface Receive as ReceiveStatus; 
	uses interface AMSend as SendStatus;
	uses interface Packet;
	uses interface Flash;
	uses interface Leds;
}
implementation {

	message_t packet;
	message_t chunk_pkt;
	message_t status_pkt;
	
	uint16_t counter = 0;
	int maxChunks = 1024;
 
	int sendIndex = 0;
	char sendArray[64];
	
	void sendMsgWithStatus( uint8_t status )
	{
		StatusMsg* statusMsg = (StatusMsg*) call Packet.getPayload(&status_pkt, sizeof(StatusMsg));
		statusMsg->status = status;
		statusMsg->id = sendIndex;
	
		if (call SendStatus.send(AM_BROADCAST_ADDR, &status_pkt, sizeof(StatusMsg) ) == SUCCESS)
		{
			// Do nothing
		}
	
	}
	
	void sendMsgWithData(uint8_t* source )
	{
		DataMsg* dataMsg = (DataMsg*) call Packet.getPayload(&chunk_pkt, sizeof(DataMsg));
	
		memcpy(dataMsg->data, source, 64);
		dataMsg->id = sendIndex;
	
		if (call SendData.send(AM_BROADCAST_ADDR, &chunk_pkt, sizeof(DataMsg)) == SUCCESS)
		{
			// Do nothing	
		}
	}
	
	event message_t* ReceiveStatus.receive(message_t* bufPtr, void* payload, uint8_t len) 
	{
		if (len != sizeof(StatusMsg)) {
			return bufPtr;
		}else{
			StatusMsg* statusMsg = (StatusMsg*)payload;
	
			if(statusMsg->status == RECEIVING)
			{
				sendIndex = 0;
				call Flash.erase();
			} else if(statusMsg->status == SENDING)
			{
				sendIndex = 0;
				call Flash.read(sendArray, sendIndex);	
			}
	
			return bufPtr;
		}
	}

	event void SendStatus.sendDone(message_t* bufPtr, error_t error) {
		
	}

	event message_t* ReceiveData.receive(message_t* bufPtr, void* payload, uint8_t len) {
		if (len != sizeof(DataMsg)) 
		{
			//do nothing
		}
		else
		{
			DataMsg* data = (DataMsg*)payload;
			call Flash.write(data->data, data->id);
			sendIndex++;
		}
		return bufPtr;
	}

	event void SendData.sendDone(message_t* bufPtr, error_t error) {
		if (&chunk_pkt == bufPtr)
		{
			sendIndex++;
	
			if(sendIndex == maxChunks)
			{
				sendMsgWithStatus(DONE);
			}
			else
			{
				call Flash.read(sendArray, sendIndex);
			}
	
		}
	
	}

	event void Control.startDone(error_t err) {
		call Leds.led2On();
	}
	
	event void Control.stopDone(error_t err) {}
	
	// Flash Events
	event void Flash.writeDone(error_t result){
		//printf("Write Done TestSerialC");
		//call Leds.led1Toggle();
		
		sendMsgWithStatus(OK);
		
		if(sendIndex == maxChunks) {
			signal TestSerialI.transferDone();
		}
	}

	event void Flash.readDone(error_t result)
	{
		//printf("Read Done TestSerialC");
		sendMsgWithData(sendArray);
	}

	event void Flash.eraseDone(error_t result)
	{
		sendMsgWithStatus(READY);
	}
	
	event void Flash.writeLengthDone(error_t result){
		//do nothing
	}
	
	event void Flash.readLengthDone(error_t result){
		//do nothing
	}
	
	event void Flash.eraseDoneFromSender(error_t result) {
		//do nothing
	}
	
	command error_t TestSerialI.start(){
		call Control.start();		
		return SUCCESS;
	}
}


