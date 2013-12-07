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

//Values to read from arduino:
int box1 = 0;
int box2 = 0;
int light1 = 0;
int light2 = 0;


//MIDI stuff
MidiBus myBus;
 
//Serial stuff
final int BYTE_MIN = 0;
final int BYTE_MAX = 1;
final boolean FAKE = false;
Serial myPort;

String serial;

//Environmental constants
final PVector KINECT_ORIGO = new PVector(0,1400,-3000); //TO BE MEASURED
final float KINECT_ANGLE = -0.862f;

final int xSize = 1280;
final int centerX = xSize * 10 / 2;
final int ySize = 860;
final int centerY = ySize * 10 / 2;


Spotlight spotlight;

//Kinect stuff
SimpleOpenNI  kinect;

PVector com = new PVector();                                   
PVector com2d = new PVector(); 

//Simulator stuff
boolean overActor = false;
boolean locked = false;
float xOffset = 0;
float yOffset = 0;


// ---------- SETUP ----------
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
  myPort = new Serial(this, Serial.list()[3], 9600);
  myPort.bufferUntil('\n');
}

void initializeDevices(){ //Remember to set everything to zero!
  myPort.write("<setServo1," + 1350 + ">");
  myPort.write("<setServo2," + 1500 + ">");
  myPort.write("<setSpotState," + 2 + ">"); 
  myPort.write("<setBoxState," + 2 + ">"); 
  myPort.write("<set1State," + 2 + ">"); 
  myPort.write("<set2State," + 2 + ">"); 
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
  room = new Room(4200, 3600, 2000);
  box = new Box();
  lights = new Light[]{
    new Light(new PVector(1000, 1000, 0)),
    new Light(new PVector(2500, 1200, -1200)),
  };

  actor = new Actor(new PVector(0, 0, -1500));
  animal = new Animal(new PVector(0, 0, 0), room);
  animal.createRelationship(actor);
}

void setup(){
  size(xSize,ySize,P3D);
  frameRate(30);
  background(0);
  
  spotlight = new Spotlight(2700);
    
  if (!FAKE) {
    serialSetup();
    kinectSetup();
    initializeDevices();
  }
  
  setupWorld();  
}

// ---------- DRAW ----------

void draw(){
  background(0);
  kinectStuff();
  drawAndSimulate();
  animal.update();
  //spotlight.target(animal.getPosition());
  
}

void drawAndSimulate(){
  pushMatrix();
  scale(0.1);
  //Set origo to center of screen
  translate(centerX, centerY);
  drawRoom();
  drawActor();
  drawRelations();
  drawAnimal();
  popMatrix();
  moveActor();

  drawInfo();
}

void drawRelations(){
  for(ActorRelation relation : animal.getRelationships()){
    PVector actorPos = get3dTo2d(relation.getActor().getPosition());
    fill(100, 50, 0);
    ellipseMode(RADIUS);
    ellipse(actorPos.x, actorPos.y, relation.getDangerRadius(), relation.getDangerRadius());
    fill(50, 100, 0);
    ellipse(actorPos.x, actorPos.y, relation.getSafeRadius(), relation.getSafeRadius());
  } 
}

void drawInfo(){
  
  fill(255);
  stroke(255);
  strokeWeight(10);
  textSize(12);
  text(frameRate, 10,10);

  text(animal.toString(), 10, 750);
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
  rect(0, - roomDepth/2 - roomHeight/2, roomWidth, roomHeight);
  rect(0, roomDepth/2 + roomHeight/2, roomWidth, roomHeight);

  //Draw box
  rect(box.getPosition().x, box.getPosition().z, 100, 100); //20x20cm box

  drawLights();
}

void drawLights(){
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
  if(locked)
    fill(0, 200, 200);
  else if(overActor)
    fill(200, 200, 0);
  else
    fill(200, 0, 200);

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
  Wall wall = room.getWall(vector3d);

  switch (wall){
    case NORTH:
      return new PVector(vector3d.x, -room.getDepth()/2 - vector3d.y);
    case SOUTH:
      return new PVector(vector3d.x, room.getDepth()/2 + vector3d.y);
    case EAST:
      return new PVector(room.getWidth()/2 + vector3d.y, vector3d.z);
    case WEST:
      return new PVector(-room.getWidth()/2 - vector3d.y, vector3d.z);
    default:
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
  //image(kinect.userImage(),0,0);
  
  int[] userList = kinect.getUsers();
  println(userList.length);
  if (userList.length >= 1){
    kinect.getCoM(userList[0], com);
    PVector transformed = transformCom(com);
    actor.setPosition(transformed);
  }
}

PVector rotateY(PVector vector, float angle){
  PVector rotRowX = new PVector(cos(angle), 0, sin(angle));
  PVector rotRowY = new PVector(0, 1, 0);
  PVector rotRowZ = new PVector(-sin(angle), 0, cos(angle));

  float rotatedX = vector.dot(rotRowX);
  float rotatedY = vector.dot(rotRowY);
  float rotatedZ = vector.dot(rotRowZ);

  return new PVector(rotatedX, rotatedY, rotatedZ);
}

String getString(PVector vec){
  return String.format("X: %.1f, Y: %.1f, Z: %.1f", vec.x, vec.y, vec.z);
}

PVector transformCom(PVector com){
  text(getString(com), 10, 100);
  PVector transformed = com.get(); //rotateY(com, KINECT_ANGLE);
  transformed.add(new PVector(0, 0, -3200));
  transformed = rotateY(transformed, KINECT_ANGLE);
  transformed.x = -transformed.x;
  text(getString(transformed), 10, 120);
  return transformed;
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
}

void mouseDragged() {

  if(locked) {
    float newX = mouseX*10 - xOffset; 
    float newY = mouseY*10 - yOffset;
    PVector oldPos = actor.getPosition();
    oldPos.x = newX;
    oldPos.z = newY;
    oldPos = room.limitToFloor(oldPos);
    actor.setPosition(oldPos);
  }
}

void mouseReleased() {

  locked = false;
}


void serialEvent(Serial p){
    String serial = myPort.readString();
    if (serial != null) {  //if the string is not empty, print the following    
      int[] a = int(split(serial, ','));
      box1 = a[0];
      box2 = a[1];
      light1 = a[2];
      light2 = a[3];
      println(box1 + " " + box2 + " " + light1 + " " + light2);
    }  
}

void onNewUser(int userID){
  //TODO: create new in-game user with link to kinect user
}

void onLostUser(int userID){
  //TODO: kill in-game user
}


