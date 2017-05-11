COMPONENT=TestSerialAppC
BUILD_EXTRA_DEPS += statusMsg.class chunkMsg.class
CLEAN_EXTRA = *.class chunkMsg.java statusMsg.java

CFLAGS += -I$(TOSDIR)/lib/T2Hack

chunkMsg.class: $(wildcard *.java) chunkMsg.java
	javac -target 1.4 -source 1.4 *.java

statusMsg.class: $(wildcard *.java) statusMsg.java
	javac -target 1.4 -source 1.4 *.java

chunkMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=chunkMsg TestSerial.h chunk_msg -o $@

statusMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=statusMsg TestSerial.h status_msg -o $@


include $(MAKERULES)

