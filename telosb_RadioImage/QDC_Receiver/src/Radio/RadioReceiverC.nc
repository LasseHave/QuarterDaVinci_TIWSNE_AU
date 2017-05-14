#include "RadioReceiver.h"
#include "Timer.h"
#include "printf.h"


module RadioReceiverC{
	provides interface RadioReceiverI; 
	uses interface AMSend;
    uses interface Packet;
    uses interface AMPacket;
    uses interface Receive;
    uses interface SplitControl as AMControl; // used to control ActiveMessageC component
    uses interface Leds;
    uses interface Timer<TMilli> as AckTimer;
}
implementation{
	uint16_t counter = 0;
	uint16_t byteCounter = 0;
	uint16_t packageCounter = 0;
	uint8_t* pictureBuffer = NULL;
	
	bool busy = FALSE;
	message_t pkt;
	error_t errorCode;
	
	command error_t RadioReceiverI.start() {
		call AMControl.start();
		return SUCCESS;
	}
	
	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
			byteCounter = 0;
			//IDLE mode should be started here
			if(pictureBuffer == NULL) {
				pictureBuffer = signal RadioReceiverI.getPictureBuffer();
			}
		}
		else {
			call AMControl.start();
		}
	}
	

	event void AMControl.stopDone(error_t err) {
	}
	
	event void AMSend.sendDone(message_t *msg, error_t error){
		// Do we need this? E.g. for ack,
		printf("ack done");
		printfflush();
	}
	
	task void sendPictureParkAck() {
		AckMsg * btrpkt = (AckMsg * )(call Packet.getPayload(&pkt,sizeof(AckMsg)));
		btrpkt->ack = 1;
		
		if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(AckMsg)) == SUCCESS) {
			
		} else {
			call AckTimer.startOneShot(1000);
		}
	}

	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		if(len == sizeof(ImageMsg)) {
			ImageMsg * btrpkt = (ImageMsg * ) payload;
			
			if (btrpkt->nodeid == 1) {
				printf("nodeid 1 received: \n");
			}
			//printf("total nr of packages: %d \n",btrpkt->total_package_nr_in_part);
			if(btrpkt->nodeid < btrpkt->total_package_nr_in_part) {
				memcpy(&pictureBuffer[(btrpkt->nodeid)*DATA_SIZE], btrpkt->data, DATA_SIZE);
				//printf("nodeid: %d, data: %d \n", btrpkt->nodeid,btrpkt->data[24]);
				call Leds.led0Toggle();
			} else {
				memcpy(&pictureBuffer[byteCounter], btrpkt->data, PICTURE_PART_SIZE-byteCounter);
				//byteCounter = byteCounter + PICTURE_PART_SIZE-byteCounter;
				printf("Node id (expexted 342)): %d   ", btrpkt->nodeid);
			}
			byteCounter = byteCounter + sizeof(btrpkt->data);
			packageCounter++;
			if (packageCounter >= 340) {
				printf("packageCounter: %d \n",packageCounter);
			}
			
			if(packageCounter >= btrpkt->total_package_nr_in_part) {
				printf("I'm alive ");
				printfflush();
				signal RadioReceiverI.packageReceived(byteCounter);
				byteCounter = 0;
				packageCounter = 0;
				call AckTimer.startOneShot(100);
			}
		}
		return msg;
	}
	
	event void AckTimer.fired(){
		post sendPictureParkAck();
	}
	


}