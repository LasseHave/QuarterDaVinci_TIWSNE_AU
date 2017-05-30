/*
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
 * Java-side application for serial communication to a telosB
 * Original made by the tinyOS project TestSerial
 */

import java.io.IOException;

import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.util.Scanner;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;
import java.io.*;
import java.awt.image.Raster;
import java.awt.Graphics;

public class TestSerial implements MessageListener {

	//"Enum Types"
	private static final short TRANSFERRING = 1;
	private static final short OK = 2;
	private static final short FAIL = 3;
	private static final short READY = 4;
	private static final short RECEIVING = 5;
	private static final short DONE = 6;

	public static MoteIF moteIF;
	public static int currentChunk;
	public static short[][] data = new short[1024][64];

	public static statusMsg status = new statusMsg();
	public static chunkMsg payload = new chunkMsg();
	
	public static boolean compressionEnabled = false;

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
			//Loading bar
			printLoading(currentChunk, false);
		}
		else if(message.amType() == statusMsg.AM_TYPE)
		{
			statusMsg msg = (statusMsg)message;
			if ((msg.get_status() == OK) ||(msg.get_status() == READY))
			{
				if(currentChunk < 1024){
					printLoading(currentChunk, true); 
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
					status.set_status(DONE);
					try{
					moteIF.send(0,status);
					System.out.println("Done sending data");
					}
					catch (IOException exception){}
					System.exit(0);
				}

			}
			else if (msg.get_status() == DONE)
			{
				// reconstruct image
				int fileSize = 65536;
				byte[] recData = getDataToRecData(data);

				try{
					FileOutputStream out = new FileOutputStream("/home/tinyos/Downloads/reimage.bmp"); 	//Make sure you have write access to the folder

					try{
						out.write((compressionEnabled ? decompress(recData, fileSize) : recData));
						out.flush();
						out.close();
						System.out.println("Image Received!");
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

	public static byte[] getDataToRecData(short[][] data){
		byte[] toReturn = new byte[65536];
		int dim1 = 0;
		int dim2 = 0;
		int recDataCount = 0;

		for (dim1 = 0; dim1 < 1024; dim1++)
		{
			for(dim2 = 0; dim2 < 64; dim2++)
				{
					toReturn[recDataCount] = (byte)data[dim1][dim2];
					recDataCount++;
			}
		}
		return toReturn;
	}
	
	public static void printLoading(int currentChunk, boolean sending){
		System.out.print("\033[H\033[2J");  // clear console
		System.out.flush();
		
		String bar = "--------------------------------";
		char[] barChars = bar.toCharArray();

		double totalChunksLoad = 1024;
		double percentSent = currentChunk / totalChunksLoad * 100;
		
		int nearest = (int) Math.round(((double)barChars.length/100)*percentSent);
		for(int i = 0; i < nearest; i++) {
			barChars[i] = 'x';
		}
		String toPrint = String.valueOf(barChars);
		String direction = "Receiving from mote";
		
		if(sending) {
			direction = "Sending to mote";
		}
		System.out.println(direction + " " + Math.round(percentSent) + "%");
		System.out.println("[" + toPrint + "] \r");
	}
	
	public static byte[] decompress(byte[] recData, int fileSize) {
		byte[] result = new byte[fileSize];
		
		byte headerLength = 30;
		for(int i = 0; i < headerLength; i++) { //bmp header
			result[i] = recData[i];
		}
		
		int j = headerLength;
		for(int i = headerLength; i < fileSize; i=(i+2)) { 
				result[i] = (byte)(recData[j] & 0xF0);
				result[i+1] = (byte) (recData[j] << 4);
				j++;
		}
		
		return result;
	}
	
	public static void getDataFromFile(File file) throws Exception{
		
		byte[] fileData = new byte[(int) file.length()];
		DataInputStream dis = new DataInputStream(new FileInputStream(file));
		dis.readFully(fileData);
		int totalChunks =  1024;
		int dim1 = 0;
		int dim2 = 0;
		int fileDataCount = 0;

		for (dim1 = 0; dim1 < totalChunks; dim1++)
		{
			for(dim2 = 0; dim2 < 64; dim2++)
			{
				data[cnt1][cnt2] = (short)fileData[fileDataCount];
				fileDataCount++;
			}
		}
	}
	
	public static void main(String[] args) throws Exception {
		String source = args[0]; 

		PhoenixSource phoenix;
		if (source == null) {
			phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
		}
		else {
			phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
		}

		MoteIF mif = new MoteIF(phoenix);
		TestSerial serial = new TestSerial(mif);
		currentChunk = 0;

		
		if(args.length > 2 && args[2].equals("c")) {
			compressionEnabled = true;
		}
		
		if(args.length > 1 && args[1].equals("r"))
    	{
			System.out.println("Requesting Data");
			status.set_status(RECEIVING);
    	}
		else
		{
			System.out.println("Choose a filename you want to transfer: ");
			Scanner scanInput = new Scanner(System.in);
	        String input = scanInput.nextLine();

			File file = new File(input + ".bmp"); 
			getDataFromFile(file);
			
			System.out.println("Sending Data");
			status.set_status(TRANSFERRING);
		}
		moteIF.send(0, status);
	}
}
