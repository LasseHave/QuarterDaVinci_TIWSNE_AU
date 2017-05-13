#include <Timer.h>
#include "RadioReceiver.h"
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
	components RadioReceiverC as RadioReceiver;
	components ActiveMessageC;
	components new AMSenderC(AM_RECEIVER);
	components new AMReceiverC(AM_RECEIVER);
	
	components PrintfC;
	
	//Storage
	
	//RadioReceiver
	
	RadioReceiver.AMControl->ActiveMessageC;
	RadioReceiver.AMSend->AMSenderC;
	RadioReceiver.Receive -> AMReceiverC;
	RadioReceiver.Leds->LedsC;

	App.RadioReceiver->RadioReceiver;
	App.Boot->MainC;
	App.Leds->LedsC;
	

}
