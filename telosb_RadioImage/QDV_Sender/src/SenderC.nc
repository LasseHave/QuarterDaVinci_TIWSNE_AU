#include <Timer.h>
#include "Sender.h"

module SenderC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl; // used to control ActiveMessageC component
}
implementation {
	uint16_t counter = 0;
	uint16_t test = 0;

	bool busy = FALSE;
	message_t pkt;

	event void Boot.booted() {
		call AMControl.start();

	}

	event void Timer0.fired() {
		counter++;
		call Leds.set(counter);
		if( ! busy) {
			ImageMsg * btrpkt = (ImageMsg * )(call Packet.getPayload(&pkt,sizeof(ImageMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->counter = counter;
			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(ImageMsg)) == SUCCESS) {
				busy = TRUE;
			}
		}
	}

	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(&pkt == msg) {	//Verifying that this is done for message sent by this component
			busy = FALSE;
		}
	}

	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}
}
