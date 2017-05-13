#include "RadioSender.h"
#include "Timer.h"
#include "printf.h"


module RadioSenderC{
	provides interface RadioSenderI; 
	uses interface AMSend;
    uses interface Packet;
    uses interface AMPacket;
    uses interface SplitControl as AMControl;
}
implementation{
	bool busy = FALSE;
	message_t pkt;
	uint8_t dataTest[28];
	uint8_t i;
	
	command error_t RadioSenderI.start() {
		call AMControl.start();
		return SUCCESS;
	}
	
	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
			signal RadioSenderI.startDone();
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
		printf("stopDone");
		printfflush();
	}

	command error_t RadioSenderI.send(uint8_t *data){
		uint8_t maxPayload = call Packet.maxPayloadLength();
		if( ! busy) {
			ImageMsg * btrpkt = (ImageMsg * )(call Packet.getPayload(&pkt,sizeof(ImageMsg)));
			btrpkt->nodeid = TOS_NODE_ID; 
			memcpy(btrpkt->data, &data[0], 26);
			
			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(ImageMsg)) == SUCCESS) {
				uint8_t size = sizeof(ImageMsg);
				busy = TRUE;
			}
		}
		return SUCCESS;
	}

	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(&pkt == msg) {	//Verifying that this is done for message sent by this component
			busy = FALSE;
			signal RadioSenderI.sendDone();
		}
	}
}