#include <Timer.h>
#include "Sender.h"
#include "printf.h"

module SenderC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	//uses interface Packet;
	//uses interface AMPacket;
	//uses interface AMSend;
	//uses interface SplitControl as AMControl; // used to control ActiveMessageC component
	uses interface RadioSenderI as RadioComm;
}
implementation {
	uint16_t counter = 0;
	uint16_t test = 0;
	bool busy = FALSE;
	uint8_t uncompressedData[1024];
	uint8_t compressedData[1024];
	
	void setDummyData(){
		uint16_t i;
		printf("Here is a uint8: %u\n", uncompressedData);
		for(i=0; i<sizeof(uncompressedData) ; i++) {
			uncompressedData[i] = (uint8_t)(i % 256);
		}
	}

	event void Boot.booted() {
		setDummyData();
		//call AMControl.start();
	}

	event void Timer0.fired() {
		counter++;
		printf("Here is a uint8: %u\n", 2);
		call Leds.set(counter);
		if( ! busy) {
			
			if(call RadioComm.Send(uncompressedData, sizeof(uncompressedData)) == SUCCESS) {
				busy = TRUE;
			}
		}
	}
	
	event void RadioComm.SendDone(){
		busy = FALSE;
	}
	

}
