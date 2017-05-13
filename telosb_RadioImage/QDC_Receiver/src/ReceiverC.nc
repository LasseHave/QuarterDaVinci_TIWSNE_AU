#include <Timer.h>
#include "Receiver.h"
#include "printf.h"

module ReceiverC {
	uses interface Boot;
	uses interface Leds;
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
				printf("Received package");
				printf("receiver length: %u\n", sizeof(ImageMsg));
				printfflush();
		if(len == sizeof(ImageMsg)) {
			ImageMsg * btrpkt = (ImageMsg * ) payload;
			uint16_t i;
			//Random test since it struggles to print entire array
			printf("Here is a uint8: %u\n", btrpkt->data[0]);
			printf("Here is a uint8: %u\n", btrpkt->data[7]);
			printf("Here is a uint8: %u\n", btrpkt->data[11]);
			printf("Here is a uint8: %u\n", btrpkt->data[20]);
			printf("Here is a uint8: %u\n", btrpkt->data[25]);
			
			
			printfflush();
			call Leds.set(++counter);
		}
		return msg;
	}
}
