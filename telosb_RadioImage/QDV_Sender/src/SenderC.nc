#include <Timer.h>
#include "RadioSender.h"
#include "printf.h"
#include <UserButton.h>


module SenderC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface RadioSenderI as RadioSender;
	uses interface SplitControl as AMControl; // used to control ActiveMessageC component
    uses interface Notify<button_state_t> as Notify;
}
implementation {
	uint16_t counter = 0;
	uint16_t test = 0;
	message_t pkt;
	
	uint8_t pictureData[IMAGE_SIZE]; 
	
	void setDummyPictureData() {
		uint16_t i;
		for (i = 0; i < IMAGE_SIZE; i++) {
			pictureData[i] = (uint8_t) (i % 255);
		}
	}
	
	event void Boot.booted() {
		setDummyPictureData();
		call AMControl.start();
	}	

	event void Timer0.fired() {
		/*counter++;
		printf("Here is a uint8: %u\n", counter);
		printfflush();
		call Leds.set(counter);
		call RadioSender.Send(&counter, sizeof(ImageMsg));*/
		
	}

	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
			//call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
			call Notify.enable();
			call Leds.led1On();
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
		printf("stopDone");
		printfflush();
	}


	event void RadioSender.SendDone(){
		printf("SendDone");
		printfflush();
	}
	
	event void Notify.notify(button_state_t state) {
		call Leds.led2Toggle();
		if (state == BUTTON_PRESSED) {
			counter++;
			call Leds.set(counter);
			call RadioSender.Send(pictureData);
		}
	}																																																																					
}
