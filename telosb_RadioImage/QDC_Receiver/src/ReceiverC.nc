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
	
	event void Boot.booted() {
		call TestSerial.start();
		call RadioReceiver.start();
	}

	// When the radio is started we need the radio to know the address of the image buffer
	event uint8_t * RadioReceiver.getPictureBuffer(){
		return pictureData;
	}
	
	
	event void RadioReceiver.packageReceived(uint16_t packageId) {
		printf("one picture part received");
		printf("Random test, should be %d: %d \n", (1000+pictureDataPartsReceived) % 255 ,pictureData[1000]);
		printf("Random test, should be %d: %d \n", (8000+pictureDataPartsReceived) % 255 ,pictureData[8000]);
		printf("Random test, should be %d: %d \n", (8191+pictureDataPartsReceived) % 255 ,pictureData[8191]);
		printf("\n");
		printfflush();
		call Flash.writeLength(pictureData, (uint32_t)pictureDataPartsReceived*PICTURE_PART_SIZE, (uint16_t) PICTURE_PART_SIZE);
		pictureDataPartsReceived++;
		call Leds.led1Toggle();
		
		if(pictureDataPartsReceived == 8) {
			call Leds.set(7);
		}
	}
	
	event void Flash.eraseDone(error_t result){
		// TODO Auto-generated method stub
	}


	event void TestSerial.transferDone(){
		// TODO Auto-generated method stub
		call Leds.led0Toggle();

	}

	event void Flash.writeDone(error_t result){
		// TODO Auto-generated method stub
		call Leds.led0Toggle();
	}

	event void Flash.readDone(error_t result){
		// TODO Auto-generated method stub
	}
}
