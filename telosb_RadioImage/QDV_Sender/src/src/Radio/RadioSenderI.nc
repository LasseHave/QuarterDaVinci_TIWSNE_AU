#include <TinyError.h>
#include <message.h>
#include <AM.h>

interface RadioSenderI
{
	command error_t Send(uint16_t* ptr, uint16_t length);
	event void SendDone();
}