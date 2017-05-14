#include <TinyError.h>
#include <message.h>
#include <AM.h>

interface RadioReceiverI
{
	command error_t start();
	event void packageReceived(uint16_t byteCounter);
	event uint8_t * getPictureBuffer();
}