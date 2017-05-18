#include <Timer.h>
#include "RadioReceiver.h"
#include "printf.h"
#include "TestSerial.h"

module ReceiverC {
	uses interface Boot;
	uses interface Leds;
	uses interface TestSerialI as TestSerial;
	uses interface Flash;
	
	uses interface RadioReceiverI as RadioReceiver;
}
implementation {	
	uint8_t pictureData[PICTURE_PART_SIZE]; 
	uint8_t pictureDataPartsReceived = 0;
	
	uint16_t flashCounter;
	
	event void Boot.booted() {
		call TestSerial.start();
		call RadioReceiver.start();
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
		if (pictureDataPartsReceived < PICTURE_PART_NR ) { // PICTURE_PART_NR
			//setDummyPictureData(10);
			call Flash.writeLength(pictureData,pictureDataPartsReceived * PICTURE_PART_SIZE, PICTURE_PART_SIZE);
			//call Flash.readLength(pictureData,0, PICTURE_PART_SIZE);
			pictureDataPartsReceived++;
		}
	}
	
	event void RadioReceiver.packageReceived(uint16_t packageId) {
		printf("one picture part received");
		printf("Random test, should be 1: %d \n", pictureData[1]);
		printf("Random test, should be 2: %d \n", pictureData[2]);
		printf("Random test, should be 3: %d \n" ,pictureData[3]);
		printf("pictureDataPartsReceived: %d \n" ,pictureDataPartsReceived);
		printf("\n");
		printfflush();
		
		flashCounter = 0;
		storePicturePartReceivedIntoFlash();
		
		call Leds.led1Toggle();
		
		
	}
	
	event void Flash.eraseDone(error_t result){
		// TODO Auto-generated method stub
	}
	
		event void TestSerial.transferDone(){
		// TODO Auto-generated method stub
		call Leds.led1On();

	}

	event void Flash.writeDone(error_t result){}

	event void Flash.readDone(error_t result){}
	
	event void Flash.eraseDoneFromSender(error_t result) {}
	
	event void Flash.readLengthDone(error_t result) {
		printf("AFTER READ DONE");
		printf("Random test, should be 1: %d \n", pictureData[1]);
		printf("Random test, should be 2: %d \n", pictureData[2]);
		printf("Random test, should be 3: %d \n" ,pictureData[3]);
		printf("\n");
		printfflush();
		call Leds.set(0);
	}
	
	event void Flash.writeLengthDone(error_t result) {
		printf("Saved to flash");
		printfflush();
		if(pictureDataPartsReceived == PICTURE_PART_NR) {//// test me agaib!!111
			
			call Leds.set(7);
			call Flash.readLength(pictureData,0, PICTURE_PART_SIZE);
		}
		call RadioReceiver.readyForNextPart();
	}
}
