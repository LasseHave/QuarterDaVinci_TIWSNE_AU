#include <TinyError.h>
#include <message.h>
#include <AM.h>

interface RadioReceiverI
{
	command error_t start();
	command void readyForNextPart();
	command error_t stop();
	event void packageReceived(uint16_t byteCounter);
	event uint8_t * getPictureBuffer();
}