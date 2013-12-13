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
int boxValue = 0;
int light1Value = 0;
int light2Value = 0;


//MIDI stuff
MidiBus myBus;
 
//Serial stuff
final int BYTE_MIN = 0;
final int BYTE_MAX = 1;
final boolean FAKE = false;
Serial servoPort;
Serial lightPort;

String serial;

//Environmental constants
final PVector KINECT_ORIGO = new PVector(0,1400,-3350); //TO BE MEASURED
final float KINECT_ANGLE = -0.785f;

final int xSize = 1280;
final int centerX = xSize * 10 / 2;
final int ySize = 860;
final int centerY = ySize * 10 / 2;


Spotlight spotlight;

//Kinect stuff
SimpleOpenNI  kinect;

PVector com = new PVector();                                   
PVector com2d = new PVector();
PVector newActorPosition = new PVector();

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
  servoPort = new Serial(this, Serial.list()[2], 9600);
  servoPort.bufferUntil('\n');
  lightPort = new Serial(this, Serial.list()[0], 9600);
  lightPort.bufferUntil('\n');
}

void initializeDevices(){ //Remember to set everything to zero!
  servoPort.write("<setServo1," + (1500+90) + ">");
  servoPort.write("<setServo2," + (1500+140) + ">");
  servoPort.write("<setSpotState," + 1 + ">"); 
  lightPort.write("<setBoxState," + 0 + ">"); 
  lightPort.write("<set1State," + 0 + ">"); 
  lightPort.write("<set2State," + 0 + ">"); 
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
  room = new Room(4200, 4200, 2000);
  box = new Box();
  lights = new Light[]{
    new Light(new PVector(1500, 0, -120)), //light 1
    new Light(new PVector(-1350, 0, 850)), //light 2
  };

  actor = new Actor(new PVector(1500, 0, -1500));
  animal = new Animal(new PVector(0, 0, 0), room);
  animal.createRelationship(actor);
  animal.discoverLight(lights[0]);
  animal.discoverLight(lights[1]);
  animal.discoverLight(box.getLight());

}

void setup(){
  size(xSize,ySize,P3D);
  frameRate(30);
  background(0);
  
  spotlight = new Spotlight(2700);
    
  if (!FAKE) {
    kinectSetup();
  }
  serialSetup();
  initializeDevices();
  midiSetup();
  setupWorld();  
}

// ---------- DRAW ----------

void draw(){
  background(0);

  if(!FAKE)
   kinectStuff();

  drawAndSimulate();
  animal.update();
  
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
  updateLights();

  drawInfo();
}

void drawRelations(){
  for(ActorRelation relation : animal.getRelationships()){
    PVector actorPos = get3dTo2d(relation.getActor().getPosition());
    fill(100, 50, 0);
    ellipseMode(RADIUS);
    ellipse(actorPos.x, actorPos.y, relation.getInterestRadius(), relation.getInterestRadius());
    fill(50, 100, 0);
    ellipse(actorPos.x, actorPos.y, relation.getDangerRadius(), relation.getDangerRadius());
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
  rect(box.getPosition().x, box.getPosition().z, boxSize, boxSize);

  drawLights();
}

float boxSize = 100;

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
  actor.setPosition(newActorPosition);
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
  updateSurround(pos);
  PVector animalPosition = animal.getPosition().get();
  //animalPosition = room.limitToFloor(animalPosition);
  spotlight.target(animalPosition);

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
    transformed = room.limitToFloor(transformed);
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
    newActorPosition = oldPos;
  }
}

void mouseReleased() {

  locked = false;
}

void keyPressed(){
  if(key == 'h'){
    animal.isInLight = false;
 //   animal.flee(actor.getPosition());
 //   servoPort.write("<setSpotState," + 1 + ">"); 
 //   servoPort.write("<setBoxState," + 0 + ">"); 
    
  }
    if(key == 'l'){
      lights[0].setTouched(1);
      lights[1].setTouched(1);
      box.getLight().setTouched(1);
    }
}

void keyReleased(){
    if(key == 'l'){
      lights[0].setTouched(0);
      lights[1].setTouched(0);
    }
}
void serialEvent(Serial p){
    String serial = lightPort.readString();
    if (serial != null) {  //if the string is not empty, print the following    
      int[] a = int(split(serial, ','));
      boxValue = a[0];
      light1Value = a[1];
      light2Value = a[2];
      
      lights[0].setTouched(light1Value);
      lights[1].setTouched(light2Value);

      println(boxValue + " " + light1Value + " " + light2Value);
    }  
}

void onNewUser(int userID){
  //TODO: create new in-game user with link to kinect user
}

void onLostUser(int userID){
  //TODO: kill in-game user
}

void updateSurround(PVector target){
  //Determine angle and map to MIDI value
  float maxRadius = 2970.0;
  float soundAngle = atan2(-target.x, target.y);
  text(degrees(soundAngle), 500,500);
  if(soundAngle >= 0){
    soundAngle = map(soundAngle, 0, PI, 0, 127/2);
  } else if(soundAngle < 0){
    soundAngle = map(soundAngle, -PI, 0, 127/2, 127);
  }
  //Determine diversity and map to MIDI value
  float diversity = map(target.mag(), 0, maxRadius, 0, 127);

  myBus.sendControllerChange(0,25,(int)diversity);
  myBus.sendControllerChange(0,24,(int)soundAngle);
}

void updateLights(){
  servoPort.write("<setSpotState," + spotlight.getState() + ">"); 
  lightPort.write("<setBoxState," + box.getLight().getState() + ">"); 
  lightPort.write("<set1State," + lights[0].getState() + ">"); 
  lightPort.write("<set2State," + lights[1].getState() + ">"); 
}

/*
Channel   CC    Control
----------------------------------
0     24    SoundAngle
0     25    Diversity
0     26    Tempo (50-177 bpm, -> 100-354 double time)
0     27    High-pass filter (box)
0     28    Low-pass filter (wool)
*/
