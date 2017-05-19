#include "Compression.h"
#include "RadioSender.h"

module QuattroBitCompressionC{
	provides interface CompressionI; 
 
}
implementation{
	
	command uint16_t CompressionI.compress(uint8_t *source, uint8_t *destination, uint16_t length){
		uint16_t i;
		
		for(i = 0; i < length/2; i++) {
			uint8_t firstHalf = source[i*2] & 0xF0; //Removes that last 4 bits. 0xF0 = 0b11110000
			uint8_t secondHalf = (source[(i*2)+1]) >> 4; //Removes that last 4 bits + bitshifting to rigth
			destination[i] = firstHalf + secondHalf;
	    }
	    
	    return (uint16_t)length/2;
	} 
}

/* Usage

		unsigned char compressed[LENGTH/2];
		unsigned char decompressed[LENGTH];

		uint16_t i;
		
		for(i = 0 ; i < LENGTH; i++)
			decompressed[i] = i%255;
		
		compress(decompressed, compressed);

*/ 