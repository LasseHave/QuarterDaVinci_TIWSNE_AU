//#include "Compression.h"
#include "RadioSender.h"


module NoCompressionC{
	provides interface CompressionI; 
 
}
implementation{
	
	command uint16_t CompressionI.compress(uint8_t *source, uint8_t *destination){
		memcpy(destination,source, PICTURE_PART_SIZE);
		return PICTURE_PART_SIZE;
	}
}