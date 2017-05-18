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
	uint8_t writeCount = 0;
	bool isSending = FALSE;
	bool first = TRUE;
	
	uint16_t shouldFlash = 0;

	uint8_t pictureData[PICTURE_PART_SIZE]; 
	//uint8_t pictureData[PICTURE_PART_SIZE / 2];
	//uint8_t pictureData2[PICTURE_PART_SIZE / 2];
	uint8_t pictureDataPart = 0;
	
	void setDummyPictureData(uint8_t add) {
		uint16_t i;
		for (i = 0; i < (PICTURE_PART_SIZE); i++) {
			pictureData[i] = (uint8_t) ((i + add)% 64);
		}
	}
	
	void loadNextPartOfPicture() {
		if(pictureDataPart < 8) {
			call Flash.readLength(pictureData,pictureDataPart*PICTURE_PART_SIZE, PICTURE_PART_SIZE);
			pictureDataPart++;
		} else {
			//Transmission done
			call Leds.set(7);
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

			
			//call Flash.read(&pictureData[shouldFlash * 64], shouldFlash * 64);
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
			call RadioSender.start();
			//counter++;
			call Leds.set(counter);
			
//			call Flash.readLength(pictureData,0, PICTURE_PART_SIZE);//why readflashlenght/write works
			
			//sendPicture();										
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
		call Leds.led1On();

	}

	event void Flash.writeDone(error_t result){
		// TODO Auto-generated method stub
	}

	event void Flash.readDone(error_t result){
		
		
		/*if(shouldFlash == 127){
			if(isSending){
				call RadioSender.send(pictureData);	
				pictureDataPart++;
			}
		}
		else{
			shouldFlash++;
			sendPicture();
		}*/

		
	}
	
	event void Flash.eraseDoneFromSender(error_t result) {
//		call Leds.led0On();
		call Flash.writeLength(pictureData, 0, PICTURE_PART_SIZE);
		//do nothing
	}
	
	event void Flash.readLengthDone(error_t result) {
		//setDummyPictureData(0);
		//call Flash.erase(TRUE);							//why readflashlenght/write works 
		
		printf("one picture part send");
		printf("Random test, should be 1: %d \n", pictureData[1]);
		printf("Random test, should be 2: %d \n", pictureData[2]);
		printf("Random test, should be 3: %d \n" ,pictureData[3]);
		printf("\n");
		printfflush();
		
		call RadioSender.send(pictureData);	//use this!
	}
	
	event void Flash.writeLengthDone(error_t result) {//why readflashlenght/write works
		if(result != SUCCESS) {
			//call Leds.led1On();
		}
		if(writeCount < 8) {
			writeCount++;
			//setDummyPictureData(writeCount);
			call Flash.writeLength(pictureData, PICTURE_PART_SIZE*writeCount, PICTURE_PART_SIZE);	
			
		} else {
			printf("Done????");
			printfflush();
			call Leds.led2Toggle();
		}
	}
}
