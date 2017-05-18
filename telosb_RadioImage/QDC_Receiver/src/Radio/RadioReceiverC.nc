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
	uint16_t byteCounter = 0;
	uint16_t packageCounter = 0;
	uint8_t* pictureBuffer = NULL;
	uint16_t lastReceivedPackage = 1000; //just initial value, must be different from 0
	uint16_t totalPackagesInPart = 0;
	
	bool busy = FALSE;
	bool savingToFlash = FALSE;
	message_t pkt;
	
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
		// If all packages in picture part received:
//		if(packageCounter >= totalPackagesInPart) {
//			printf("I'm alive ");
//			printfflush();
//			byteCounter = 0;
//			packageCounter = 0;
//			signal RadioReceiverI.packageReceived(byteCounter);
//		}
	}
	
	task void sendPictureParkAck() {
		AckMsg * btrpkt = (AckMsg * )(call Packet.getPayload(&pkt,sizeof(AckMsg)));
		btrpkt->ack = lastReceivedPackage;
		//printf("ackk pck: %d \n", lastReceivedPackage);
		//printfflush();
		if(packageCounter >= totalPackagesInPart) {
			printf("I'm alive ");
			printfflush();
			byteCounter = 0;
			packageCounter = 0;
			savingToFlash = TRUE;
			signal RadioReceiverI.packageReceived(byteCounter);
		} else { //If it's the last package in set of packages, we wait sending the ack.
			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(AckMsg)) == SUCCESS) {
				
				
			} else {
				call AckTimer.startOneShot(10);
			}
		}
	}
	// Every time we receive a package
	event message_t * Receive.receive(message_t * msg, void * payload,
			uint8_t len) {
		if(!savingToFlash && len == sizeof(ImageMsg)) {
			ImageMsg * btrpkt = (ImageMsg * ) payload;
			
			if(btrpkt->nodeid != lastReceivedPackage) { // We do not want the same package twice
				totalPackagesInPart = btrpkt->total_package_nr_in_part;
				lastReceivedPackage = btrpkt->nodeid;
				if(btrpkt->nodeid < btrpkt->total_package_nr_in_part-1) {
					memcpy(&pictureBuffer[(btrpkt->nodeid)*DATA_SIZE], btrpkt->data, DATA_SIZE); // it copies the set of data into a proper memory address
					call Leds.led0Toggle();
				} else {
					memcpy(&pictureBuffer[byteCounter], btrpkt->data, (PICTURE_PART_SIZE-byteCounter)); // put it into the last memory position
				}
				byteCounter = byteCounter + sizeof(btrpkt->data); // how many bytes we received
				packageCounter++;
			}
			
			call AckTimer.startOneShot(1); // w8 one milisecond - just for the acknowledgment ot work
		}
		return msg;
	}
	
	event void AckTimer.fired(){
		// post is put into the schedule
		post sendPictureParkAck(); //send acknowledgment 
	}
	
	command void RadioReceiverI.readyForNextPart() {
		savingToFlash = FALSE;
		if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(AckMsg)) == SUCCESS) {
				
				
		} else {
			call AckTimer.startOneShot(10);
		}
	}
}