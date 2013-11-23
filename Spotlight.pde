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

PVector getPosition(){
  return spotPosition;
}

void target(PVector target){
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
