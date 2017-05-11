#include <Timer.h>
#include "RadioSender.h"
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
	components RadioSenderC;
	

	
	components RadioSenderC as RadioSender;
	components new AMSenderC(AM_SENDER);
	
	
	components PrintfC;
	
	//Block storage
	
	// Serial
	
	RadioSender.Packet->AMSenderC;
	RadioSender.AMPacket->AMSenderC;
	RadioSender.AMSend->AMSenderC;

	App.Boot->MainC;
	App.Leds->LedsC;
	App.Timer0->Timer0;
	App.AMControl->ActiveMessageC;
	App.RadioSender->RadioSenderC;
}
