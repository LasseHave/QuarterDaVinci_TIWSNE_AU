#include <Timer.h>
#include "RadioSender.h"
#include "TestSerial.h"
#include "printf.h"
#include <UserButton.h>


module SenderC {
	uses interface Boot;
	uses interface Leds;
	uses interface RadioSenderI as RadioSender;
    uses interface Notify<button_state_t> as Notify;
    uses interface Flash;
    uses interface TestSerialI as TestSerial;
}
implementation {
	uint16_t counter = 0;

	uint8_t pictureData[PICTURE_PART_SIZE]; 
	uint8_t pictureDataPart = 0;
	
	void setDummyPictureData(uint8_t add) {
		uint16_t i;
		for (i = 0; i < (PICTURE_PART_SIZE); i++) {
			pictureData[i] = (uint8_t) ((i + add)% 255);
		}
	}
	
	void sendPicture() {
		if(pictureDataPart < 8) {
			//load next part of picture
			setDummyPictureData(pictureDataPart);
			call RadioSender.send(pictureData);
			//flashPtr++;
			pictureDataPart++;
		} else 
		{
			//Picture sent
			call Leds.set(7);
			pictureDataPart = 0;
		}
		
	}
	
	event void Boot.booted() {
		call TestSerial.start();
		call RadioSender.start();
	}	


	event void RadioSender.startDone(){
		call Notify.enable();
		call Leds.led1On();
	}
	

	event void RadioSender.sendDone(){
		sendPicture();
		printf("SendDone");
	}
	
	event void Notify.notify(button_state_t state) {
		call Leds.led2Toggle();
		if (state == BUTTON_PRESSED) {
			counter++;
			call Leds.set(counter);
			sendPicture();
		}
	}																																																																					

	event void Flash.readDone(error_t result){
		printf("Read done");
		printfflush();
	}

	event void Flash.writeDone(error_t result){
		printf("Write done");
		printfflush();
	}


	event void Flash.eraseDone(error_t result){
		// TODO Auto-generated method stub
	}


	event void TestSerial.transferDone(){
		// TODO Auto-generated method stub
		call Leds.led0Toggle();

	}
}
