#include <Timer.h>
#include "RadioReceiver.h"
#include "printf.h"
#include "TestSerial.h"
#include "StorageVolumes.h"

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
	components new AMSenderC(AM_SENDER);
	components new AMReceiverC(AM_RECEIVER);
	components new TimerMilliC() as AckTimer;
	
	components new TimerMilliC() as RadioStartTimer;
	
	components PrintfC;
	
	components TestSerialC as TestSerial;
	components SerialActiveMessageC as AM;
	components FlashC;
	components new BlockStorageC(BLOCK_VOLUME);
	//Storage
	
	//RadioReceiver
	
	RadioReceiver.AMControl->ActiveMessageC;
	RadioReceiver.AMSend->AMSenderC;
	RadioReceiver.Receive -> AMReceiverC;
	RadioReceiver.Leds->LedsC;
	RadioReceiver.Packet->AMSenderC;
	RadioReceiver.AckTimer->AckTimer;

	App.RadioReceiver->RadioReceiver;
	App.Boot->MainC;
	App.Leds->LedsC;
	App.TestSerial->TestSerial;
	App.Flash -> FlashC;
	App.RadioStartTimer -> RadioStartTimer;
	
		//SERIAL
	TestSerial.Control -> AM;
	TestSerial.ReceiveData -> AM.Receive[AM_CHUNK_MSG_T];
	TestSerial.SendData -> AM.AMSend[AM_CHUNK_MSG_T];
	TestSerial.ReceiveStatus -> AM.Receive[AM_STATUS_MSG_T];
	TestSerial.SendStatus -> AM.AMSend[AM_STATUS_MSG_T];
	TestSerial.Packet -> AM;
	TestSerial.Flash -> FlashC;
	TestSerial.Leds -> LedsC;
	
	FlashC.BlockRead -> BlockStorageC.BlockRead;
	FlashC.BlockWrite -> BlockStorageC.BlockWrite;
	
	
	
	

}
