#include "RadioSender.h"
#include "Timer.h"
#include "printf.h"

module RadioSenderC{
	provides interface RadioSenderI; 
	uses interface AMSend;
    uses interface Packet;
    uses interface AMPacket;
}
implementation{
	bool busy = FALSE;
	message_t pkt;

	command error_t RadioSenderI.Send(uint16_t *counter, uint16_t length){
		if( ! busy) {
			ImageMsg * btrpkt = (ImageMsg * )(call Packet.getPayload(&pkt,sizeof(ImageMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->counter = *counter;
			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(ImageMsg)) == SUCCESS) {
				busy = TRUE;
			}
		}
		return SUCCESS;
	}

	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(&pkt == msg) {	//Verifying that this is done for message sent by this component
			busy = FALSE;
		}
	}
}