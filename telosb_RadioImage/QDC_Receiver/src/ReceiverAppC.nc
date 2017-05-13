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
	
	//Receiver specific
	components ReceiverC as App;
	components ActiveMessageC;
	components new AMSenderC(AM_RECEIVER);
	components new AMReceiverC(AM_RECEIVER);
	
	components PrintfC;
	
	//Storage
	
	//More for serial communication
	

	App.Boot->MainC;
	App.Leds->LedsC;
	App.AMControl->ActiveMessageC;
	App.AMSend->AMSenderC;
	App.Receive -> AMReceiverC;

}
