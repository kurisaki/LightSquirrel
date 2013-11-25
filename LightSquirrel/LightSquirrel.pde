/**
*
*  Serial communication protocol adapted from
*  Luke Sturgeon <l.sturgeon@edu.ciid.dk>
*
*/

import SimpleOpenNI.*;
import processing.serial.*;
import themidibus.*;
import java.util.*;



//MIDI stuff
MidiBus myBus;
 
//Serial stuff
final int BYTE_MIN = 0;
final int BYTE_MAX = 1;
final boolean FAKE = true;
Serial myPort;


final PVector kinectOrigo = new PVector(0,1400,-3000); //TO BE MEASURED

int xSize = 640;
int ySize = 480;


Spotlight spotlight;

//Kinect stuff
SimpleOpenNI  kinect;

PVector com = new PVector();                                   
PVector com2d = new PVector(); 

//Stuff to read from Arduino
int boxVal = 0;


void kinectSetup(){
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  // enable depthMap generation 
  kinect.enableDepth();
  // enable skeleton generation for all joints
  kinect.enableUser();
}

void serialSetup(){
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[4], 9600);
  myPort.bufferUntil('\n');
}

void initializeDevices(){
  myPort.write("<setServo1," + 1350 + ">");
  myPort.write("<setServo2," + 2400 + ">");
  myPort.write("<setSpotState," + 0 + ">"); 
  myPort.write("<setBoxState," + 1 + ">"); 
  myPort.write("<set1State," + 0 + ">"); 
  myPort.write("<set2State," + 0 + ">"); 
}

void midiSetup(){
  MidiBus.list();
  myBus = new MidiBus(this, -1, "Buss 1");
}

void setup(){
  size(xSize,ySize);
  frameRate(30);
  background(0);
  
  spotlight = new Spotlight(2400);

  if (!FAKE) {
    serialSetup();
    kinectSetup();
    initializeDevices();
    //REMAP 
    translate(kinectOrigo.x, -kinectOrigo.y, -kinectOrigo.z);
  }
  

  
}

// ---------- DRAW ----------

float yPos = 0;

void draw(){
  background(0);
  fill(255);


  background(204);
  yPos = yPos - 1.0;
  if (yPos < 0) {
    yPos = height;
  }
  line(0, yPos, width, yPos);

  if(!FAKE)
    kinectStuff();
  
}

void kinectStuff(){
  kinect.update();
  //Draw user cam for debugging
  image(kinect.userImage(),0,0);
  
  int[] userList = kinect.getUsers();
  println(userList.length);
  if (userList.length >= 1){
    kinect.getCoM(userList[0],com);
    spotlight.target(com);
  }
}

/*void MIDI(){ //examples of possible MIDI controllers for surround sound!
  int diversity = 127; //distance from center  
  myBus.sendControllerChange(0,25,diversity);
  int soundAngle = 0; //angle, clockwise
  myBus.sendControllerChange(0,24,soundAngle);
}*/
