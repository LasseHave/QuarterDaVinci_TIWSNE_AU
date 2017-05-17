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
}
implementation {
	uint16_t counter = 0;
	uint16_t picCount = 0;
	bool isSending = FALSE;
	
	uint16_t shouldFlash = 0;

	uint8_t pictureData[PICTURE_PART_SIZE]; 
	//uint8_t pictureData[PICTURE_PART_SIZE / 2];
	//uint8_t pictureData2[PICTURE_PART_SIZE / 2];
	uint8_t pictureDataPart = 0;
	
	void setDummyPictureData(uint8_t add) {
		uint16_t i;
		for (i = 0; i < (PICTURE_PART_SIZE/2); i++) {
			pictureData[i] = (uint8_t) ((i + add)% 255);
		}
	}
	
	
	void sendPicture() {
		if(pictureDataPart < 8) {
			//load next part of picture from flash
			//setDummyPictureData(pictureDataPart);
			isSending = TRUE;
			call Leds.led0Off();
			call Leds.led1Off();
			call Leds.led2Off();
			/*if(call Flash.readLength(pictureData,pictureDataPart*PICTURE_PART_SIZE, PICTURE_PART_SIZE) == SUCCESS) {
				call Leds.led1On();
			} else {
				call Leds.led0On();
			}*/

			
			call Flash.read(&pictureData[shouldFlash * 64], shouldFlash * 64);
			//call Flash.readLength(pictureData,pictureDataPart*PICTURE_PART_SIZE, PICTURE_PART_SIZE);
			
		
		} else 
		{
			//Picture sent
			call Leds.set(7);
			isSending = FALSE;
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
		//send next part of the picture
		sendPicture();
		printf("SendDone");
	}
	
	event void Notify.notify(button_state_t state) {
		call Leds.led2Toggle();
		if (state == BUTTON_PRESSED) {
			counter++;
			call Leds.set(counter);
			sendPicture();
			//setDummyPictureData(0);
			//call Flash.writeLength(pictureData, 0, PICTURE_PART_SIZE/2);
			//call Flash.write(pictureData, 0);

		}
	}																																																																					

	


	event void Flash.eraseDone(error_t result){
		// TODO Auto-generated method stub
	}


	event void TestSerial.transferDone(){
		// TODO Auto-generated method stub
		//call Leds.led0Toggle();

	}

	event void Flash.writeDone(error_t result){
		// TODO Auto-generated method stub
		//call Leds.led0Toggle();
		//call Flash.read(pictureData2, 0);
	}

	event void Flash.readDone(error_t result){
		
		if(shouldFlash == 127){
			if(isSending){
				call RadioSender.send(pictureData);	
				pictureDataPart++;
			}
		}
		else{
			shouldFlash++;
			sendPicture();
		}

		
	}
}
