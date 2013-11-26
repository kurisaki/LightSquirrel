class Spotlight{//FIELDS

private PVector spotPosition;

PVector ZYcomponent;
PVector XYcomponent;

final float OFFSET = 85; //fixed, distance from base to optical axis

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

void target(PVector target){
  PVector targetVector = PVector.sub(target, spotPosition);
  
  ZYcomponent = new PVector(0,targetVector.y,targetVector.z);
  XYcomponent = new PVector(targetVector.x, targetVector.y, 0);
  
  float angleZY;
  float angleXY;
  
  if(targetVector.z<0){
    angleZY = -degrees(PVector.angleBetween(targetVector,XYcomponent));
  } else {
    angleZY = degrees(PVector.angleBetween(targetVector,XYcomponent));
  }
    if(targetVector.x<0){
    angleXY = -degrees(PVector.angleBetween(targetVector,ZYcomponent));
  } else {
    angleXY = degrees(PVector.angleBetween(targetVector,ZYcomponent));
  }
  
  //Remember to calibrate servos!
  int servo1 = (int)map(angleZY, -90,90,700,2100);
  servo1 = constrain(servo1, 700,2100);
  int servo2 = (int)map(angleXY, -90,90,700,2100);
  servo2 = constrain(servo2, 700,2100);

  myPort.write("<setServo1," + servo1 + ">");
  myPort.write("<setServo2," + servo2 + ">");
  }
  
}
