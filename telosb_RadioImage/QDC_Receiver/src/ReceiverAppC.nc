#include <Timer.h>
#include "Receiver.h"

configuration ReceiverAppC {
}
implementation {
	components MainC;
	components LedsC;
	components ReceiverC as App;
	components ActiveMessageC;
	components new AMSenderC(AM_RECEIVER);
	components new AMReceiverC(AM_RECEIVER);

	App.Boot->MainC;
	App.Leds->LedsC;
	App.AMControl->ActiveMessageC;
	App.AMSend->AMSenderC;
	App.Receive -> AMReceiverC;
}
