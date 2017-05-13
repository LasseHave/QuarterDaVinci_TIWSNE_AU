#include <Timer.h>
#include "RadioSender.h"
#include "printf.h"
#include <UserButton.h>


module SenderC {
	uses interface Boot;
	uses interface Leds;
	uses interface RadioSenderI as RadioSender;
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
		call RadioSender.start();
	}	


	event void RadioSender.startDone(){
		call Notify.enable();
		call Leds.led1On();
	}
	

	event void RadioSender.sendDone(){
		printf("SendDone");
		printfflush();
	}
	
	event void Notify.notify(button_state_t state) {
		call Leds.led2Toggle();
		if (state == BUTTON_PRESSED) {
			counter++;
			call Leds.set(counter);
			call RadioSender.send(pictureData);
		}
	}																																																																					
}
