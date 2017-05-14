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
	
	uint8_t pictureData[PICTURE_PART_SIZE]; 
	uint8_t pictureDataPart = 0;
	
	event void Boot.booted() {
		call RadioReceiver.start();

	}

	event uint8_t * RadioReceiver.getPictureBuffer(){
		return pictureData;
	}
	
	
	event void RadioReceiver.packageReceived(uint16_t packageId) {
		byteCounter = byteCounter + 1;
		printf("one picture part received");
		printf("Random test, should be %d: %d \n", 1000 % 255 ,pictureData[1000]);
		printf("\n");
		
		//printf("LastElement 254: %d \n",pictureData[PICTURE_PART_SIZE-1]);
		
		printfflush();
		call Leds.led1Toggle();
	}
}
