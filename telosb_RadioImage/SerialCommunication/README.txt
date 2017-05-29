README for TestSerial
Author/Contact: tinyos-help@millennium.berkeley.edu

Description:

Built from original TestSerial.
TestSerial is a simple application that may be used to test that the
TinyOS java toolchain can communicate with a mote over the serial
port. The java application sends packets to the serial port at 1Hz:
the packet contains an incrementing counter. When the mote application
receives a counter packet, it displays the bottom three bits on its
LEDs. (This application is similar to RadioCountToLeds, except that it
operates over the serial port.) Likewise, the mote also sends packets
to the serial port at 1Hz. Upon reception of a packet, the java
application prints the counter's value to standard out.

Java Application Usage:
  
  $ cd to this folder

  $ java TestSerial [source] <r> <c>

  Source is written as: serial@/dev/ttyUSB0:telosb, or whatever port is used.

  <r> Receive from telosB flash
  <c> If c is passed, the transmission will be compressed.

  If changes made in java, call:
  $ javac TestSerial.Java