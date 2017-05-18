#include "Compression.h"

#define LENGTH 1024

module DueBitCompressionC{
	provides interface CompressionI; 
 
}
implementation{
	
	command uint16_t CompressionI.compress(uint8_t *source, uint8_t *destination){
		uint16_t i, j;
		
		for(i = 0; i < LENGTH/4; i++) {
			uint16_t sourceIndex = i*4, 
			uint16_t destIndex = i*3;

			for (j = 0; j < 3; j++){
				destination[destIndex+j] = (source[sourceIndex+j] & 0xFC) | ((source[sourceIndex+3] >> (6-j*2)) & 3);
			}
			    
	        
	    }
	    
	    return (uint16_t)destination; //Is this right?
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