#include <Timer.h>
#include "RadioReceiver.h"
#include "printf.h"

module ReceiverC {
	uses interface Boot;
	uses interface Leds;
	
	uses interface RadioReceiverI as RadioReceiver;
}
implementation {	
	uint8_t pictureData[PICTURE_PART_SIZE]; 
	uint8_t pictureDataPartsReceived = 0;
	
	event void Boot.booted() {
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
		pictureDataPartsReceived++;
		call Leds.led1Toggle();
		
		if(pictureDataPartsReceived == 8) {
			call Leds.set(7);
		}
	}
}
