#include <Timer.h>
#include "RadioReceiver.h"
#include "printf.h"
#include "TestSerial.h"

module ReceiverC {
	uses interface Boot;
	uses interface Leds;
	uses interface TestSerialI as TestSerial;
	uses interface Flash;
	uses interface Timer<TMilli> as RadioStartTimer;
	uses interface RadioReceiverI as RadioReceiver;
}
implementation {	
	uint8_t pictureData[PICTURE_PART_SIZE]; 
	uint8_t decompressedPictureData[PICTURE_PART_SIZE]; 
	uint8_t pictureDataPartsReceived = 0;
	bool compressionEnabled = TRUE;
	
	event void Boot.booted() {
		call TestSerial.start();
		call RadioStartTimer.startOneShot(3000);
		//call RadioReceiver.start();
	}
	
	void setDummyPictureData(uint8_t add) {
		uint16_t i;
		for (i = 0; i < (PICTURE_PART_SIZE); i++) {
			pictureData[i] = (uint8_t) ((i + add)% 64);
		}
	}

	// When the radio is started we need the radio to know the address of the image buffer
	event uint8_t * RadioReceiver.getPictureBuffer(){
		return pictureData;
	}
	
	void storePicturePartReceivedIntoFlash() {
		if (pictureDataPartsReceived < PICTURE_PART_NR ) { 
			if(compressionEnabled) {
				call Flash.writeLength(pictureData,pictureDataPartsReceived * (PICTURE_PART_SIZE/2), (PICTURE_PART_SIZE/2));
			} else {
				call Flash.writeLength(pictureData,pictureDataPartsReceived * PICTURE_PART_SIZE, PICTURE_PART_SIZE);
			}
		}
	}
	
	event void RadioReceiver.packageReceived(uint16_t packageId) {
		call Leds.led1Toggle();
		storePicturePartReceivedIntoFlash();
	}
	
	event void Flash.writeLengthDone(error_t result) {
		pictureDataPartsReceived++;
		if(pictureDataPartsReceived == PICTURE_PART_NR) {
			call RadioReceiver.stop();
			//call Leds.set(0);
		}		
		call RadioReceiver.readyForNextPart();
	}
	
	//Unhandled events
	event void Flash.eraseDone(error_t result){}
	
	event void TestSerial.transferDone(){}

	event void Flash.writeDone(error_t result){}

	event void Flash.readDone(error_t result){}
	
	event void Flash.readLengthDone(error_t result) {}

	event void RadioStartTimer.fired(){
		// TODO Auto-generated method stub
		call RadioReceiver.start();
	}
}
