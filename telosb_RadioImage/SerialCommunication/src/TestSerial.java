/*									tab:4
 * "Copyright (c) 2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose, without fee, and without written
 * agreement is hereby granted, provided that the above copyright
 * notice, the following two paragraphs and the author appear in all
 * copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY
 * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
 * DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS
 * DOCUMENTATION, EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */

/**
 * Java-side application for testing serial port communication.
 * 
 *
 * @author Phil Levis <pal@cs.berkeley.edu>
 * @date August 12 2005
 */

import java.io.IOException;

import java.awt.image.BufferedImage;

import javax.imageio.ImageIO;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;
import java.io.*;
import java.awt.image.Raster;
import java.awt.Graphics;

public class TestSerial implements MessageListener {

	private static final short TRANSFER_TO_TELOS = 1;
	private static final short TRANSFER_OK = 2;
	private static final short TRANSFER_FAIL = 3;
	private static final short TRANSFER_READY = 4;
	private static final short TRANSFER_FROM_TELOS = 5;
	private static final short TRANSFER_DONE = 6;


	public static MoteIF moteIF;

	public static int currentChunk;

	public static int isReady = 0;
	public static short[][] data = new short[1024][64];

	public static statusMsg status = new statusMsg();
	public static chunkMsg payload = new chunkMsg();


	public TestSerial(MoteIF moteIF) {
		this.moteIF = moteIF;
		this.moteIF.registerListener(new chunkMsg(), this);
		this.moteIF.registerListener(new statusMsg(), this);
	}

	public void messageReceived(int to, Message message) {
		if(message.amType() == chunkMsg.AM_TYPE)
		{
			chunkMsg msg = (chunkMsg)message;
			short[] buf = msg.get_chunk();
			currentChunk = msg.get_chunkNum();
			data[currentChunk] = buf;
			System.out.println("Received chunk:" + currentChunk);
			//currentChunk++;
		}
		else if(message.amType() == statusMsg.AM_TYPE)
		{
			statusMsg msg = (statusMsg)message;
			if ((msg.get_status() == TRANSFER_OK) ||(msg.get_status() == TRANSFER_READY))
			{
				System.out.println("Got OK");
				if(currentChunk < 1024){
					System.out.println("Sending packet " + currentChunk);
					payload.set_chunk(data[currentChunk]);
					payload.set_chunkNum(currentChunk);
					currentChunk++;
					try{
						moteIF.send(0, payload);
					}
					catch (IOException exception)
					{
						System.err.println("Exception throw when sending data:");
						System.err.println(exception);
					}
				}
				else
				{
					currentChunk = 0;
					status.set_status(TRANSFER_DONE);
					try{
					moteIF.send(0,status);
					System.out.println("Done sending data");
					}
					catch (IOException exception){}
					System.exit(0);
					//try {Thread.sleep(1000);}
					//catch (InterruptedException exception) {}
					//status.set_status(TRANSFER_FROM_TELOS);
					//
					//	moteIF.send(0, status);
					//	System.out.println("Requesting Data");
					//}
					//catch (IOException exception){}
				}

			}
			else if (msg.get_status() == TRANSFER_DONE)
			{
				System.out.println("Transfer is done. Reconstructing...");
				// reconstruct image
				File file = new File("clock.tiff");
				byte[] recData = new byte[(int) file.length()];
				int cnt1 = 0;
				int cnt2 = 0;
				int cnt3 = 0;
				System.out.println("Transfer is done. Reconstructing...");

				for (cnt1 = 0; cnt1 < 1024; cnt1++)
				{
					for(cnt2 = 0; cnt2 < 64; cnt2++)
					{

						recData[cnt3] = (byte)data[cnt1][cnt2];
						cnt3++;
					}
					System.out.println("Do i actually do something???..." + cnt2);

				}
				try{
					System.out.println("Do i get to the try?...");

					FileOutputStream out = new FileOutputStream("/home/tinyos/Downloads/reimage.tiff", );
					//Make sure you have write access to the folder
					try{
						
						out.write(recData);
						out.flush();
						out.close();
						System.out.println("Image reconstruction completed");
						System.exit(0);
					}
					catch(IOException exception){}
				}
				catch(FileNotFoundException exception){}

			}
		}
		else
		{
			System.out.println("unknown message");
		}
	}

	public static void main(String[] args) throws Exception {
		String source = null;
		//RandomAccessFile f = new RandomAccessFile("image.bin", "r");
		source = "serial@/dev/ttyUSB0:telosb";
		PhoenixSource phoenix;
		if (source == null) {
			phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
		}
		else {
			phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
		}
		//statusMsg status = new statusMsg();
		//chunkMsg payload = new chunkMsg();
		MoteIF mif = new MoteIF(phoenix);
		TestSerial serial = new TestSerial(mif);
		currentChunk = 0;

		File file = new File("clock.tiff");
		byte[] fileData = new byte[(int) file.length()];
		DataInputStream dis = new DataInputStream(new FileInputStream(file));
		dis.readFully(fileData);
		int totalChunks =  1024; // 256 * 256 / 64
		//short[][] data = new short[totalChunks][64]; 
		int cnt1 = 0;
		int cnt2 = 0;
		int cnt3 = 0;

		for (cnt1 = 0; cnt1 < totalChunks; cnt1++)
		{
			for(cnt2 = 0; cnt2 < 64; cnt2++)
			{
				data[cnt1][cnt2] = (short)fileData[cnt3];
				cnt3++;
			}
		}
		
		if(args[0].equals("r"))
    	{
			System.out.println("Requesting Data");
			status.set_status(TRANSFER_FROM_TELOS);
    	}
		else
		{
			System.out.println("Sending Data");
			status.set_status(TRANSFER_TO_TELOS);
		}
		moteIF.send(0, status);
	}
}
