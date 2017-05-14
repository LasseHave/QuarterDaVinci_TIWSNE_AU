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
	components ActiveMessageC;
	components RadioSenderC;
	components UserButtonC;
	
	components RadioSenderC as RadioSender;
	components new AMSenderC(AM_SENDER);
	components new AMReceiverC(AM_RECEIVER);
	components new TimerMilliC() as AckTimer;

	components PrintfC;

	//Block storage

	// Serial

	//RadioSender
	RadioSender.Packet->AMSenderC;
	RadioSender.AMPacket->AMSenderC;
	RadioSender.AMSend->AMSenderC;
	RadioSender.AMControl->ActiveMessageC;
	RadioSender.Receive -> AMReceiverC;
	RadioSender.AckTimer -> AckTimer;
	
	App.Boot->MainC;
	App.Leds->LedsC;
	App.RadioSender->RadioSenderC;

	//Button
	App.Notify->UserButtonC;
}