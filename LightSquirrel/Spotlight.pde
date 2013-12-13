class Spotlight implements HasPosition{
//FIELDS

private PVector spotPosition;

PVector ZYcomponent;
PVector XYcomponent;

final float OFFSET = 85; //fixed, distance from base to optical axis

int state = 1; //0 = off, 1 = on

//CONSTRUCTOR - presume aligned vertically with box
public Spotlight(int roomHeight){
  spotPosition = new PVector(0, roomHeight - OFFSET, 0);
  ZYcomponent = new PVector(0,0,0);
  XYcomponent = new PVector(0,0,0);
}


//METHODS

PVector getPosition(){
  return spotPosition;
}

public int getState(){
  return state;
}

public void setState(int i){
  state = i;
}

void target(PVector target){
  PVector targetVector = PVector.sub(target, spotPosition);
  
  ZYcomponent = new PVector(0,targetVector.y,targetVector.z);
  XYcomponent = new PVector(targetVector.x, targetVector.y, 0);
  
  float angleZY;
  float angleXY;
  
  if(targetVector.z<0){
    angleZY = degrees(PVector.angleBetween(targetVector,XYcomponent));
  } else {
    angleZY = -degrees(PVector.angleBetween(targetVector,XYcomponent));
  }
    if(targetVector.x<0){
    angleXY = - degrees(PVector.angleBetween(targetVector,ZYcomponent));
  } else {
    angleXY = degrees(PVector.angleBetween(targetVector,ZYcomponent));
  }
  
  //Remember to calibrate servos!
  int servo2 = (int)map(angleZY, -90,90,600+140,2400+140);
  servo2 = constrain(servo2, 700,2300);
  int servo1 = (int)map(angleXY, -90,90,600+100,2400+100);
  servo1 = constrain(servo1, 700,2300);

  servoPort.write("<setServo1," + servo1 + ">");
  servoPort.write("<setServo2," + servo2 + ">");
  }

}

