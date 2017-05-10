#include <Timer.h>
#include "Receiver.h"
#include "printf.h"

configuration ReceiverAppC {
}
implementation {
	//Main
	components MainC;
	
	//IO
	components LedsC;
	components PrintfC;
	
	//Receiver specific
	components ReceiverC as App;
	components ActiveMessageC;
	components new AMSenderC(AM_RECEIVER);
	components new AMReceiverC(AM_RECEIVER);
	
	
	//Storage
	//components new BlockStorageC(SIZE_IMAGE) as ImageStorage;
	
	//More for serial communication
	

	App.Boot->MainC;
	App.Leds->LedsC;
	App.AMControl->ActiveMessageC;
	App.AMSend->AMSenderC;
	App.Receive -> AMReceiverC;
}
