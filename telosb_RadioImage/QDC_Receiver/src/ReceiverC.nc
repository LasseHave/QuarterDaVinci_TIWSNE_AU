#include <Timer.h>
#include "Receiver.h"


module ReceiverC {
	uses interface Boot;
	uses interface Leds;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl; // used to control ActiveMessageC component
	uses interface Receive;
	uses interface RadioReceiverI as RadioComm;
}
implementation {
	uint16_t counter = 0;

	bool busy = FALSE;
	message_t pkt;
	uint8_t uncompressedData[1024];
	uint8_t compressedData[1024];
	uint16_t blockCount = 0;
	
	event uint8_t * RadioComm.GetBuffer(uint16_t length){
		return uncompressedData;
	}
	
	event void RadioComm.PacketReceived(uint16_t length, error_t error){
		if(error == SUCCESS) {
			int i;
			
			blockCount = (++blockCount)%65;
			
			//Set flash data
			printf("%u", blockCount);
			
			if(blockCount == 0) {
				call Leds.led2Toggle();
			}
			
		} else {
			call Leds.led0Toggle();
		}
	}
	

	event void Boot.booted() {
		call AMControl.start();

	}

	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(&pkt == msg){	//Verifying that this is done for message sent by this component
			busy = FALSE;
		}
	}

	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
			//IDLE mode should be started here
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		
		if(len == sizeof(ImageMsg)) {
			ImageMsg * btrpkt = (ImageMsg * ) payload;
			call Leds.set(btrpkt->counter);
			printf("Here is a uint8: %u\n", btrpkt->counter);
		}
		return msg;
	}
}
