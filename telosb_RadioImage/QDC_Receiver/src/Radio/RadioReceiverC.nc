#include "RadioReceiver.h"
#include "Timer.h"
#include "printf.h"


module RadioReceiverC{
	provides interface RadioReceiverI; 
	uses interface AMSend;
    uses interface Packet;
    uses interface AMPacket;
    uses interface Receive;
    uses interface SplitControl as AMControl; // used to control ActiveMessageC component
    uses interface Leds;
}
implementation{
	uint16_t counter = 0;
	uint16_t byteCounter = 0;

	bool busy = FALSE;
	message_t pkt;
	
	command error_t RadioReceiverI.start() {
		call AMControl.start();
		return SUCCESS;
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
	
	event void AMSend.sendDone(message_t *msg, error_t error){
		// Do we need this? E.g. for ack
	}

	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		if(len == sizeof(ImageMsg)) {
			ImageMsg * btrpkt = (ImageMsg * ) payload;
			uint16_t i;
			call Leds.set(++counter);
			//byteCounter = byteCounter + sizeof(btrpkt->data);
			signal RadioReceiverI.packageReceived(btrpkt->nodeid);
		}
		return msg;
	}


}