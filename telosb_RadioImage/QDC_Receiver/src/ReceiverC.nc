#include <Timer.h>
#include "RadioReceiver.h"
#include "printf.h"

module ReceiverC {
	uses interface Boot;
	uses interface Leds;
	
	uses interface RadioReceiverI as RadioReceiver;
}
implementation {
	uint16_t packagesReceived = 0;
	uint16_t byteCounter = 0;
	event void Boot.booted() {
		call RadioReceiver.start();

	}

	
	event void RadioReceiver.packageReceived(uint16_t byteCount) {
		printf("Byte counter: %u  ", byteCount);
		printfflush();
	}
}
