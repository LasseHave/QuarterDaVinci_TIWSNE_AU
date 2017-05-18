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
	uint16_t sentBytes = 0;
	uint8_t *dataPtr;
	uint16_t packageCounter;
	uint16_t totalPackages;
	
	
	command error_t RadioSenderI.start() {
		call AMControl.start();
		return SUCCESS;
	}
	
	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
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
	
	/*
	 * Method to calculate number of packages to be sent
	 */
	void calculateTotalNumberOfPackagesInPart(uint16_t numberOfBytes) {
		totalPackages = (numberOfBytes / DATA_SIZE);
		// add one more package if there is something left after the division
		if((numberOfBytes % DATA_SIZE) != 0) {
			totalPackages++;
		}
	}
	
	void createSinglePackage(uint16_t fromIndex, uint8_t lenght) {
		ImageMsg * btrpkt = (ImageMsg * )(call Packet.getPayload(&pkt,sizeof(ImageMsg)));
		btrpkt->nodeid = packageCounter;//TOS_NODE_ID; 
		btrpkt->total_package_nr_in_part = totalPackages;
		memcpy(btrpkt->data, &dataPtr[fromIndex], lenght);
	}
	
	void sendPackage() {
		if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(ImageMsg)) == SUCCESS) {
				busy = TRUE;
		} else {
			printf("ERROR WHEN SENDING PACKAGE");
		}
	}

	command error_t RadioSenderI.send(uint8_t *data, uint16_t numberOfBytes){
		if( ! busy) {
			if(sentBytes == 0) { // initial call
				calculateTotalNumberOfPackagesInPart(numberOfBytes);
				packageCounter = 0;
				dataPtr = data;
				createSinglePackage(0, DATA_SIZE);
				sentBytes = sentBytes + DATA_SIZE;
			}
			sendPackage();
		}
		return SUCCESS;
	}
	
	void prepareNextPackage() {
			if((sentBytes + DATA_SIZE) > PICTURE_PART_SIZE) {
				createSinglePackage(sentBytes, PICTURE_PART_SIZE - sentBytes);
			} else {
				createSinglePackage(sentBytes, DATA_SIZE);
			}
			sentBytes = sentBytes + DATA_SIZE;
	}

	// If we haven't receivedacknowledgment within 5 second we try to retransmitt'
	event void AMSend.sendDone(message_t * msg, error_t error) {
			call AckTimer.startOneShot(500);
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		if(len == sizeof(AckMsg)) {
			AckMsg * btrpkt = (AckMsg * ) payload;
			call AckTimer.stop();
			
			if(btrpkt->ack == packageCounter) {					//If ack received is the last sent? Else resend
				if(packageCounter >= totalPackages-1) {			//Are all packages from part of picture sent?
					printf("Ack one done: %d", btrpkt->ack);
					printfflush();
					busy = FALSE;
					sentBytes = 0;
					signal RadioSenderI.sendDone();
				} else {
					packageCounter++;
					prepareNextPackage();
					sendPackage();
				}
			} else {
				sendPackage();
			}
			
			
		}
		return msg;
	}
	
	event void AckTimer.fired() {
    	//If this fires, ack not received, trying to resend 
    	printf("Ack never recived, retransmitting last package");
    	printfflush();
    	sendPackage();
  }
	

}