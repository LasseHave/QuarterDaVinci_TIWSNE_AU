#include <TinyError.h>
#include <message.h>
#include <AM.h>

interface TestSerialI{
	command error_t start();
	event void transferDone();
}


