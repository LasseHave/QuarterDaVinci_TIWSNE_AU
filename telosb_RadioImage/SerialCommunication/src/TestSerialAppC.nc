#include "TestSerial.h"
#include "Timer.h"
#include <UserButton.h>
#include "Flash.h"
#include "StorageVolumes.h"

configuration TestSerialAppC {}
implementation {
	components TestSerialC as App, MainC;
	components SerialActiveMessageC as AM;
	components FlashC;
	components new BlockStorageC(BLOCK_VOLUME);

	App.Boot -> MainC.Boot;
	App.Control -> AM;
	App.ReceiveData -> AM.Receive[AM_CHUNK_MSG_T];
	App.SendData -> AM.AMSend[AM_CHUNK_MSG_T];
	App.ReceiveStatus -> AM.Receive[AM_STATUS_MSG_T];
	App.SendStatus -> AM.AMSend[AM_STATUS_MSG_T];
	App.PacketAck -> AM.PacketAcknowledgements;
	
	App.Packet -> AM;
 
	App.Flash -> FlashC;
	FlashC.BlockRead -> BlockStorageC.BlockRead;
	FlashC.BlockWrite -> BlockStorageC.BlockWrite;
}


