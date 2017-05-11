#include <Timer.h>
#include "RadioSender.h"
#include "printf.h"

module SenderC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface RadioSenderI as RadioSender;
	uses interface SplitControl as AMControl; // used to control ActiveMessageC component
}
implementation {
	uint16_t counter = 0;
	uint16_t test = 0;
	message_t pkt;
	
	event void Boot.booted() {
		call AMControl.start();
	}

	event void Timer0.fired() {
		counter++;
		printf("Here is a uint8: %u\n", 2);
		call Leds.set(counter);
		call RadioSender.Send(&counter, sizeof(ImageMsg));
		
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
		printf("stopDone");
	}


	event void RadioSender.SendDone(){
		printf("SendDone");
	}
}
