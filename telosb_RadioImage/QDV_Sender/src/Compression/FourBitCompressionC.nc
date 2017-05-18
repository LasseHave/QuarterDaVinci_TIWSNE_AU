#include "Compression.h"

#define LENGTH 1024

module FourBitCompressionC{
	provides interface CompressionI; 
 
}
implementation{
	
	command uint16_t CompressionI.compress(uint8_t *source, uint8_t *destination){
		uint16_t i;
		
		for(i = 0; i < LENGTH; i++) {
			if(i % 2 == 0){
				destination[i] = source[i] & 0xF0;
			}
	        else{
	       		destination[i] += source[i] >> 4;
	       	}
	        
	    }
	    
	    return (uint16_t)destination; //Is this right?
	} 
}