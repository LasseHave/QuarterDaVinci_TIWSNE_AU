#include "Compression.h"


module NoCompressionC{
	provides interface CompressionI; 
 
}
implementation{
	
	command uint16_t CompressionI.compress(uint8_t *source, uint8_t *destination){
		memcpy(destination,source, BLOCK_LENGTH);
		return BLOCK_LENGTH;
	}
}