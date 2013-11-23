import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 
import processing.serial.*; 
import themidibus.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LightFlight2_0 extends PApplet {

/**
*
*  Serial communication protocol adapted from
*  Luke Sturgeon <l.sturgeon@edu.ciid.dk>
*
*/








//MIDI stuff
MidiBus myBus;
 
//Serial stuff
final int BYTE_MIN = 0;
final int BYTE_MAX = 1;
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


public void kinectSetup(){
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

public void serialSetup(){
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[4], 9600);
  myPort.bufferUntil('\n');
}


public void midiSetup(){
  MidiBus.list();
  myBus = new MidiBus(this, -1, "Buss 1");
}


public void setup(){
  size(xSize,ySize);
  background(0);
  
  serialSetup();
  kinectSetup();
  spotlight = new Spotlight(2400);
  
  //initialize devices
  myPort.write("<setServo1," + 1350 + ">");
  myPort.write("<setServo2," + 2400 + ">");
  myPort.write("<setSpotState," + 0 + ">"); 
  myPort.write("<setBoxState," + 1 + ">"); 
  myPort.write("<set1State," + 0 + ">"); 
  myPort.write("<set2State," + 0 + ">"); 
  
  //REMAP 
  translate(kinectOrigo.x, -kinectOrigo.y, -kinectOrigo.z);
  
}

// ---------- DRAW ----------

public void draw(){
  background(0);
  fill(255);
  kinectStuff();
  
}

public void kinectStuff(){
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
class Actor{
//FIELDS
PVector position;
float acceleration;
float speed;
final int speedAvgFrames = 10;
final int accelAvgFrames = 30;
LinkedList<PVector> history = new LinkedList<PVector>();
LinkedList<Float> speedHistory = new LinkedList<Float>();

//CONSTRUCTOR
public Actor(PVector p){
  position = p;
}

//METHODS
public void setPosition(PVector p){
  position = p;
  
  history.add(p);

  if(history.size()>speedAvgFrames){
    history.remove();
  }

  PVector temp = history.get(0).get();
  for(int i=1; i<history.size();i++){
    temp.sub(history.get(i));
  }
  speed = temp.mag();

  speedHistory.add(speed);

  if(speedHistory.size()>accelAvgFrames){
    speedHistory.remove();
  }
    float tempAccel = 0;
  for (int i = 1; i<speedHistory.size(); i++){
    float lastSpeed = speedHistory.get(i-1);
    float newSpeed = speedHistory.get(i);
    tempAccel = abs(newSpeed-lastSpeed);
  }
    acceleration = tempAccel/(speedHistory.size()-1);
}

public float getSpeed(){
  return speed;
}

public float getAccel(){
  return acceleration;
}

}
class ActorRelation{

//FIELDS
	Actor actor;
	int attitude; //-10 to +10
	int interest; // -10 to +10
	int dangerRadius;
	int safeRadius;

//CONSTRUCTOR
public ActorRelation(Actor target){
	actor = target;
	attitude = 0;
	interest = 0;
	dangerRadius = 1000;
	safeRadius = 2000;
}

public Actor getActor(){
	return actor;
}

public int getAttitude(){
	return attitude;
}

public int getInterest(){
	return interest;
}

public int getDangerRadius(){
	return dangerRadius;
}

public int getSafeRadius(){
	return safeRadius;
}

public PVector getActorVector(PVector animalPosition){
	PVector something = new PVector(0,0,0);
	return something;
}


}
class Animal{

//FIELDS
PVector position;
State state;
ArrayList<ActorRelation> relationships; 
ArrayList<Light> lightsThatIKnow;
Box box;

//CONSTRUCTOR
public Animal(PVector initialPosition){
	position = initialPosition;
	state = State.RESTING;
	relationships = new ArrayList<ActorRelation>();

}

//METHODS

public void lookAround(){
	for (ActorRelation relation : relationships){

	}

}

}
class Box{

//FIELDS

final PVector position = new PVector(0,0,0); // ORIGO!
Light boxLight;
int openState; //0=closed, 1=half open, 2=full open

//CONSTRUCTOR
public Box(){
	boxLight = new Light(position);
	openState = 0;
}

//METHODS

public void setState(int aState){
	openState = aState;
}

public Light getLight(){
	return boxLight;
}
}

class Light{

//FIELDS
PVector position;
int state;	//0=off, 1=on, 2=breathe
int frequency; //only applicable when breathing.


//CONSTRUCTOR(S)
public Light(PVector p, int s, int f){
	position = p;
	state = s;
	frequency = f;
}

public Light(PVector p){
	position = p;
	state = 0;
	frequency = 3000;
}

//METHODS
	public void setState(int aState){
		state = aState;
	}

	public void setFrequency(int aFrequency){
		frequency = aFrequency;
	}
}


//FIELDS
int xWidth;
int zDepth;
int yHeight;
//Presume square room/active area

//CONSTRUCTOR
public void Room(int x, int z, int y){
  xWidth = x;
  zDepth = z;
  yHeight = y;
}


//METHODS
class Spotlight{//FIELDS

private PVector spotPosition;

PVector ZYcomponent;
PVector XYcomponent;
PVector targetVector;

final float OFFSET = 85; //fixed, distance from base to optical axis

//CONSTRUCTOR - presume aligned vertically with box
public Spotlight(int roomHeight){
  spotPosition = new PVector(0, roomHeight - OFFSET, 0);
  ZYcomponent = new PVector(0,0,0);
  XYcomponent = new PVector(0,0,0);
  targetVector = new PVector(0,0,0);
}


//METHODS

public PVector getPosition(){
  return spotPosition;
}

public void target(PVector target){
  targetVector = PVector.sub(target, spotPosition);
  
  ZYcomponent = new PVector(0,target.y,target.z);
  XYcomponent = new PVector(target.x, target.y, 0);
  
  float angleZY;
  float angleXY;
  
  if(targetVector.z<0){
    angleZY = -degrees(PVector.angleBetween(targetVector,ZYcomponent));
  } else {
    angleZY = degrees(PVector.angleBetween(targetVector,ZYcomponent));
  }
    if(targetVector.x<0){
    angleXY = -degrees(PVector.angleBetween(targetVector,XYcomponent));
  } else {
    angleXY = degrees(PVector.angleBetween(targetVector,XYcomponent));
  }
  
  int servo1 = (int)map(angleZY, -90,90,450,2250);
  int servo2 = (int)map(angleXY, -90,90,750,2550);
  myPort.write("<setServo1," + servo1 + ">");
  myPort.write("<setServo2," + servo2 + ">");
  }
  
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "LightFlight2_0" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
