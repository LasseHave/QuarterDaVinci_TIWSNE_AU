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
	components RadioSenderC as Sender;
	
	//Block storage
	
	// Serial


	//Sender mapping
	Sender.AMSend -> AMSenderC;
	Sender.AMControl -> ActiveMessageC;
	Sender.Packet -> AMSenderC;
	
	//Main mapping
	App.Boot->MainC;
	App.Leds->LedsC;
	App.Timer0->Timer0;
	//App.Packet->AMSenderC;
	//App.AMPacket->AMSenderC;
	//App.AMSend->AMSenderC;
	//App.AMControl->ActiveMessageC;
	App.RadioComm -> Sender;
}
