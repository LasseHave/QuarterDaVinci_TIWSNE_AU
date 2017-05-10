#include <TinyError.h>
#include <message.h>
#include <AM.h>

interface RadioReceiverI{
	command error_t Start();
	
	event uint8_t* GetBuffer(uint16_t length);
	
	event void PacketReceived(uint16_t length, error_t error);
	
	command error_t Stop();
}