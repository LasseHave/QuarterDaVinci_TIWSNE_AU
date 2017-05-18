#include "Compression.h"
#include "RadioSender.h"

module DueBitCompressionC{
	provides interface CompressionI; 
 
}
implementation{
	
	command uint16_t CompressionI.compress(uint8_t *source, uint8_t *destination){
		uint16_t i, j;
		
		for(i = 0; i < PICTURE_PART_SIZE; i++) {
			uint16_t sourceIndex = i*4; 
			uint16_t destIndex = i*3;

			for (j = 0; j < 3; j++){
				destination[destIndex+j] = (source[sourceIndex+j] & 0xFC) | ((source[sourceIndex+3] >> (6-j*2)) & 3);
			}
	    }
	    
	    return (uint16_t)(PICTURE_PART_SIZE/4)*3;
	} 
}

/* Usage

		unsigned char compressed[BLOCK_LENGTH*3/4];
		unsigned char decompressed[BLOCK_LENGTH];
		uint16_t i;

		for(i = 0; i < BLOCK_LENGTH; i++)
			decompressed[i] = i;
		
		compress(decompressed, compressed);

*/ 