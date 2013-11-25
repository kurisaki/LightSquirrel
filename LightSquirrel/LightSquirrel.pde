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

final int xSize = 1024;
final int centerX = xSize * 10 / 2;
final int ySize = 768;
final int centerY = ySize * 10 / 2;


Spotlight spotlight;

//Kinect stuff
SimpleOpenNI  kinect;

PVector com = new PVector();                                   
PVector com2d = new PVector(); 

//Stuff to read from Arduino
int boxVal = 0;


//Simulator stuff
boolean overActor = false;
boolean locked = false;
float xOffset = 0;
float yOffset = 0;


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

// ------- World and actors --------
Room room;
Box box;
Light[] lights;
Actor actor;
Animal animal;

void setupWorld(){
  room = new Room(5000, 5000, 2400); //Room is 5 x 5 x 2.4 meters
  box = new Box();
  lights = new Light[]{
    new Light(new PVector(1000, 1000, 0)),
    new Light(new PVector(2500, 1200, -1200)),
  };

  actor = new Actor(new PVector(0, 1000, -1500));
  animal = new Animal(new PVector(0, 0, 0));
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
  
  setupWorld();
  
}

// ---------- DRAW ----------

float yPos = 0;

void draw(){
  background(0);
  fill(0);
  stroke(255);
  strokeWeight(10);


  if(!FAKE) {
    kinectStuff();
  } else {
    pushMatrix();

    scale(0.1);
    //Set origo to center of screen
    translate(centerX, centerY);
    drawRoom();
    drawActor();
    drawAnimal();
    popMatrix();

    moveActor();

    animal.lookAround();
  }
  
}

void drawRoom(){
  //Draw floor
  fill(0);
  rectMode(CENTER);
  int roomWidth = room.getWidth();
  int roomDepth = room.getDepth();
  int roomHeight = room.getHeight();

  rect(0, 0, roomWidth, roomDepth);
  rect(- roomWidth/2 - roomHeight/2, 0, roomHeight, roomDepth);
  rect(roomWidth/2 + roomHeight/2, 0, roomHeight, roomDepth);

  //Draw box
  rect(box.getPosition().x, box.getPosition().z, 100, 100); //20x20cm box

  for (Light l : lights){
    switch (l.getState()){
      case 2:
        fill(100);
        break;
      default :
        fill(0);
      break;  
    }
    PVector vector2d = get3dTo2d(l.getPosition());
    ellipse(vector2d.x, vector2d.y, 100, 100);
  }
}


  float actorWidth = 300;
  float actorHeight = 300;

void drawActor() {
  fill(0, 200, 200);

  PVector actorPos = get3dTo2d(actor.getPosition());
  rect(actorPos.x, actorPos.y, actorWidth, actorHeight);
}

void moveActor() {
  PVector actorPos = get3dTo2d(actor.getPosition());
  PVector centerV = new PVector(centerX, centerY);
  actorPos.add(centerV);

  // Test if the cursor is over the actor 
  if (mouseX*10 > actorPos.x - actorWidth && mouseX*10 < actorPos.x + actorWidth && 
      mouseY*10 > actorPos.y - actorHeight && mouseY*10 < actorPos.y + actorHeight) {
    overActor = true;
  } else {
    overActor = false;
  }
}

PVector get3dTo2d(PVector vector3d) {
  boolean isOnLeftWall = vector3d.x == room.getWidth() / 2;
  boolean isOnRightWall = vector3d.x == room.getWidth() / -2;


  if(isOnLeftWall){
    return new PVector(-room.getWidth()/2 - vector3d.y, vector3d.z);
  } else if(isOnRightWall){
    return new PVector(room.getWidth()/2 + vector3d.y, vector3d.z);
  } else {
    return new PVector(vector3d.x, vector3d.z);
  }
}

void drawAnimal() {
  PVector pos = get3dTo2d(animal.getPosition());

  fill(255, 0, 0);
  ellipse(pos.x, pos.y, 100, 100);
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

// -------------- MOUSE ---------------
void mousePressed() {
  if(overActor) { 
    locked = true; 
  } else {
    locked = false;
  }

  PVector pos = get3dTo2d(actor.getPosition());
  xOffset = mouseX*10 -pos.x; 
  yOffset = mouseY*10 -pos.y; 

  println("mouseX: "+mouseX);
  println("mouseY: "+mouseY);
  println("locked: "+locked);
}

void mouseDragged() {
  if(locked) {
    float newX = mouseX*10 - xOffset; 
    float newY = mouseY*10 - yOffset;
    PVector oldPos = actor.getPosition();
    oldPos.x = newX;
    oldPos.z = newY;
    actor.setPosition(oldPos);
  }
}

void mouseReleased() {
  locked = false;
}

/*void MIDI(){ //examples of possible MIDI controllers for surround sound!
  int diversity = 127; //distance from center  
  myBus.sendControllerChange(0,25,diversity);
  int soundAngle = 0; //angle, clockwise
  myBus.sendControllerChange(0,24,soundAngle);
}*/
