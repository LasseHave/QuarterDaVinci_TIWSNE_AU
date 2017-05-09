#include <Timer.h>
#include "Sender.h"

configuration SenderAppC {
}
implementation {
	components MainC;
	components LedsC;
	components SenderC as App;
	components new TimerMilliC() as Timer0;
	components ActiveMessageC;
	components new AMSenderC(AM_SENDER);

	App.Boot->MainC;
	App.Leds->LedsC;
	App.Timer0->Timer0;
	App.Packet->AMSenderC.Acks;
	App.AMPacket->AMSenderC;
	App.AMSend->AMSenderC;
	App.AMControl->ActiveMessageC;
}
