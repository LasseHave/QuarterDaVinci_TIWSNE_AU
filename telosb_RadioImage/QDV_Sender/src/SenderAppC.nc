#include <Timer.h>
#include "Sender.h"
#include "printf.h"

configuration SenderAppC {
}
implementation {
	//Main
	components MainC;
	
	//IO
	components LedsC;
	components SenderC as App;
	components new TimerMilliC() as Timer0;
	components ActiveMessageC;
	components new AMSenderC(AM_SENDER);
	
	components PrintfC;
	
	//Block storage
	
	// Serial

	App.Boot->MainC;
	App.Leds->LedsC;
	App.Timer0->Timer0;
	App.Packet->AMSenderC;
	App.AMPacket->AMSenderC;
	App.AMSend->AMSenderC;
	App.AMControl->ActiveMessageC;
}
