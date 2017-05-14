#include "RadioSender.h"
#include "Timer.h"
#include "printf.h"


module RadioSenderC{
	provides interface RadioSenderI; 
	uses interface AMSend;
    uses interface Packet;
    uses interface AMPacket;
    uses interface SplitControl as AMControl;
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
	
	void createSinglePackage(uint16_t fromIndex, uint8_t lenght) {
		ImageMsg * btrpkt = (ImageMsg * )(call Packet.getPayload(&pkt,sizeof(ImageMsg)));
		btrpkt->nodeid = ++packageCounter;//TOS_NODE_ID; 
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
			}
			
			sendPackage();
		}
		return SUCCESS;
	}

	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(&pkt == msg) {	//Verifying that this is done for message sent by this component
			if (sentBytes < PICTURE_PART_SIZE) {
				
				if((sentBytes + DATA_SIZE) > PICTURE_PART_SIZE) {
					printf("Made it here");
					printfflush();
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
				signal RadioSenderI.sendDone();
			}
		}
	}
}