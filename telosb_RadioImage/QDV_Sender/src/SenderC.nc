#include <Timer.h>
#include "RadioSender.h"
#include "TestSerial.h"
#include "printf.h"
#include <UserButton.h>
#include "Flash.h"

module SenderC {
	uses interface Boot;
	uses interface Leds;
	uses interface RadioSenderI as RadioSender;
    uses interface Notify<button_state_t> as Notify;
    uses interface Flash;
    uses interface TestSerialI as TestSerial;
    uses interface Timer<TMilli> as ButtonTimer;
    uses interface CompressionI as Compression;
}
implementation {
	uint8_t temp[PICTURE_PART_SIZE]; 
	uint8_t pictureData[PICTURE_PART_SIZE]; 
	uint8_t pictureDataPart = 0;
	
	bool buttonReleased = TRUE;
	bool compression = FALSE;
	
	void setDummyPictureData(uint8_t add) {
		uint16_t i;
		for (i = 0; i < (PICTURE_PART_SIZE); i++) {
			pictureData[i] = (uint8_t) ((i + add)% 64);
		}
	}
	
	void loadNextPartOfPicture() {
		if(pictureDataPart < PICTURE_PART_NR) {
			if(compression) {
				printf("Load picture with compression");
				printfflush();
				call Flash.readLength(temp,pictureDataPart*PICTURE_PART_SIZE, PICTURE_PART_SIZE);
			} else {
				printf("Load picture without compression");
				printfflush();
				call Flash.readLength(pictureData,pictureDataPart*PICTURE_PART_SIZE, PICTURE_PART_SIZE);
			}
			pictureDataPart++;
		} else {
			//Transmission done
			call Leds.set(7);
		}
	}
	
	
	event void Boot.booted() {
		call Notify.enable();
		call TestSerial.start();
	}	


	event void RadioSender.startDone(){
		//call Notify.enable();
		call Leds.led1On();
		loadNextPartOfPicture();
	}
	

	event void RadioSender.sendDone(){
		//send next part of the picture
		loadNextPartOfPicture();
		printf("SendDone");
	}
	
	event void Notify.notify(button_state_t state) {
		if (state == BUTTON_PRESSED) {
			buttonReleased = FALSE;
			call ButtonTimer.startOneShot(500);
		} else if (state == BUTTON_RELEASED) {
			buttonReleased = TRUE;
		}
		
	}
	
	event void ButtonTimer.fired(){
		if(buttonReleased) {
			//Send without compression
			compression = FALSE;
		} else {
			//Send with compression
			compression = TRUE;
		}
		call RadioSender.start();
		call Leds.set(0);
	}																																																																					

	event void Flash.eraseDone(error_t result){
		// TODO Auto-generated method stub
		
	}


	event void TestSerial.transferDone(){
		// TODO Auto-generated method stub
		call Leds.led1On();

	}
	
	event void Flash.readLengthDone(error_t result) {
		uint16_t numberOfBytes = PICTURE_PART_SIZE;
		if(compression) {
			numberOfBytes = call Compression.compress(temp, pictureData);
		}
		call RadioSender.send(pictureData, numberOfBytes);
	}

	//Unhandled events
	event void Flash.writeDone(error_t result){}

	event void Flash.readDone(error_t result){}
	
	event void Flash.eraseDoneFromSender(error_t result) {}
	
	event void Flash.writeLengthDone(error_t result) {}
}
