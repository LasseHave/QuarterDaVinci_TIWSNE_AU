#include "Decompression.h"


module NoCompressionC{
	provides interface DecompressionI; 
 
}
implementation{
	
	command void DecompressionI.decompress(uint8_t *source, uint8_t *destination){
		memcpy(destination,source,BLOCK_LENGTH);
	}
}