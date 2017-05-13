#include <TinyError.h>
#include <message.h>
#include <AM.h>

interface RadioSenderI
{
	command error_t Send(uint8_t* ptr);
	event void SendDone();
}