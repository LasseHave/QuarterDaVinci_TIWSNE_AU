#include "Radio.h"

module RadioReceiverC
{
	provides interface RadioReceiverI; 
	uses interface Receive;
	uses interface SplitControl as AMControl;
	uses interface Packet;
}
implementation
{
	bool reciving = FALSE;
	uint8_t* buffer = NULL; 
	uint16_t lastID = 0; 
	uint16_t Rxlen = 0; 

	void ReceiveDone(error_t error)
	{
		signal RadioReceiverI.PacketReceived(Rxlen, error);
		buffer = NULL; 
		lastID = 0; 
		Rxlen = 0;
	}

	event void AMControl.stopDone(error_t error)
	{
		if(reciving)
			call AMControl.start();
	}

	event void AMControl.startDone(error_t error)
	{
		if(error != SUCCESS)
		{
			reciving = FALSE;
			ReceiveDone(FAIL);
			return;
		}
		return; 
	}

	command error_t RadioReceiverI.Start()
	{
		if(reciving == FALSE)
		{
			call AMControl.start();
			reciving = TRUE;
			return SUCCESS;	
		}
		return FAIL;
	}

	command error_t RadioReceiverI.Stop()
	{
		ReceiveDone(FAIL);
		reciving = FALSE;
		call AMControl.stop();
		return SUCCESS;
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		if (len != sizeof(radio_packet_msg_t) || reciving == FALSE) 
			return msg;
			
		else 
		{
			radio_packet_msg_t* rcm = (radio_packet_msg_t*)payload;
			
			if(buffer == NULL && rcm->ID == 1)
				buffer = signal RadioReceiverI.GetBuffer(rcm->TotalSize);
			
			if(buffer != NULL)
			{					
				if(lastID+1 == rcm->ID)
				{
					int i = 0; 
					lastID++; 
					memcpy(&buffer[(rcm->ID-1)*PAYLOADSIZE], rcm->Data, rcm->len);
					Rxlen += rcm->len;
			
					if(Rxlen == rcm->TotalSize)
						ReceiveDone(SUCCESS);
				}
				else
					ReceiveDone(FAIL);
			}
		}
		return msg;
	}
}