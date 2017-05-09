#include <Timer.h>
#include "Receiver.h"

configuration ReceiverAppC {
}
implementation {
	components MainC;
	components LedsC;
	components BlinkToRadioC as App;
	components new TimerMilliC() as Timer0;
	components ActiveMessageC;
	components new AMReceiverC(AM_RECEIVER);

	App.Boot->MainC;
	App.Leds->LedsC;
	App.Timer0->Timer0;
	App.AMControl->ActiveMessageC;
	App.Receive -> AMReceiverC;
}
