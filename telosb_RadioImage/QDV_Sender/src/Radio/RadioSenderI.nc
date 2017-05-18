#include <TinyError.h>
#include <message.h>
#include <AM.h>

interface RadioSenderI
{
	command error_t start();
	event void startDone();
	command error_t send(uint8_t* ptr, uint16_t numberOfBytes);
	event void sendDone();
}