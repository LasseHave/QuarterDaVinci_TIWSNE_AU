#include <Timer.h>
#include "Receiver.h"

module ReceiverC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl; // used to control ActiveMessageC component
	uses interface Receive;
}
implementation {
	uint16_t counter = 0;

	bool busy = FALSE;
	message_t pkt;

	event void Boot.booted() {
		call AMControl.start();

	}

	event void Timer0.fired() {
		counter++;

		if( ! busy) {
			ReceiverMsg * btrpkt = (ReceiverMsg * )(call Packet.getPayload(&pkt,
					sizeof(ReceiverMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->counter = counter;
			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(ReceiverMsg)) == SUCCESS) {
				busy = TRUE;
			}
		}
	}

	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(&pkt == msg){	//Verifying that this is done for message sent by this component
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

	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		if(len == sizeof(ReceiverMsg)) {
			ReceiverMsg * btrpkt = (ReceiverMsg * ) payload;
			call Leds.set(btrpkt->counter);
		}
		return msg;
	}
}
