#include <Timer.h>
#include "RadioReceiver.h"
#include "printf.h"

module ReceiverC {
	uses interface Boot;
	uses interface Leds;
	
	uses interface RadioReceiverI as RadioReceiver;
}
implementation {
	event void Boot.booted() {
		call RadioReceiver.start();

	}

	
	event void RadioReceiver.packageReceived() {
		printf("Package Received!");
		printfflush();
	}
}
