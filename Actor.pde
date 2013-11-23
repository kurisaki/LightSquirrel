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