interface Flash
{
	command error_t erase();
	event void eraseDone(error_t res);
		
	command error_t write(uint8_t* arrPtr, uint32_t pktNum);
	event void writeDone(error_t res);

	command error_t read(uint8_t* arrPtr, uint32_t pktNum);
	event void readDone(error_t res);
	
	command error_t readLength(uint8_t* arrPtr, uint32_t from, uint16_t len);
	event void readLengthDone (error_t res);
	
	command error_t writeLength(uint8_t* arrPtr, uint32_t from, uint16_t len);
	event void writeLengthDone (error_t res);
	
}