#include "RadioSender.h"
#include "Timer.h"
#include "printf.h"


module RadioSenderC{
	provides interface RadioSenderI; 
	uses interface AMSend;
    uses interface Packet;
    uses interface AMPacket;
    uses interface Receive;
    uses interface SplitControl as AMControl;
    uses interface Timer<TMilli> as AckTimer;
    
}
implementation{
	bool busy = FALSE;
	message_t pkt;
	uint16_t sentBytes;
	uint8_t *dataPtr;
	uint16_t packageCounter;
	
	
	command error_t RadioSenderI.start() {
		call AMControl.start();
		return SUCCESS;
	}
	
	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
			sentBytes = 0;
			signal RadioSenderI.startDone();
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
		printf("stopDone");
		printfflush();
	}
	
	uint16_t calculateTotalNumberOfPackagesInPart() {
		uint16_t totalPackages = (PICTURE_PART_SIZE / DATA_SIZE);
		if((PICTURE_PART_SIZE % DATA_SIZE) != 0) {
			totalPackages++;
		}
		return totalPackages;
	}
	
	void createSinglePackage(uint16_t fromIndex, uint8_t lenght) {
		ImageMsg * btrpkt = (ImageMsg * )(call Packet.getPayload(&pkt,sizeof(ImageMsg)));
		//packageCounter++;
		btrpkt->nodeid = packageCounter;//TOS_NODE_ID; 
		packageCounter++;
		btrpkt->total_package_nr_in_part = calculateTotalNumberOfPackagesInPart();
		memcpy(btrpkt->data, &dataPtr[fromIndex], lenght);
	}
	
	void sendPackage() {
		if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(ImageMsg)) == SUCCESS) {
				uint8_t size = sizeof(ImageMsg);
				busy = TRUE;
		} else {
			printf("ERROR WHEN SENDING PACKAGE");
		}
	}

	command error_t RadioSenderI.send(uint8_t *data){
		if( ! busy) {
			if(sentBytes == 0) { // initial call
				packageCounter = 0;
				dataPtr = data;
				createSinglePackage(0, DATA_SIZE);
				sentBytes = sentBytes + DATA_SIZE;
			}
			printf("packet 0: %d", dataPtr[0] );
			printf("packet 2: %d ", dataPtr[2] );
			printf("packet 4: %d", dataPtr[4] );
			printfflush();
			sendPackage();
		}
		return SUCCESS;
	}

	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(&pkt == msg) {	//Verifying that this is done for message sent by this component
			if (sentBytes < PICTURE_PART_SIZE) {
				
				if((sentBytes + DATA_SIZE) > PICTURE_PART_SIZE) {
					createSinglePackage(sentBytes, PICTURE_PART_SIZE - sentBytes);
				} else {
					createSinglePackage(sentBytes, DATA_SIZE);
				}
				sentBytes = sentBytes + DATA_SIZE;
				sendPackage();
			} else 
			{
				busy = FALSE;
				sentBytes = 0;
				call AckTimer.startOneShot(5000);
				//Wait for ack to be returned from receiver
			}
		}
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		if(len == sizeof(AckMsg)) {
			call AckTimer.stop();
			printf("Ack received");
			printfflush();
			signal RadioSenderI.sendDone();
			//signal RadioSenderI.sendDone();
		}
		return msg;
	}
	
	event void AckTimer.fired() {
		//Wait with next part of picture until an ack is received
    	//If this fires, ack not received 
    	printf("Ack never recived, transmission stopped");
    	printfflush();
  }
	

}