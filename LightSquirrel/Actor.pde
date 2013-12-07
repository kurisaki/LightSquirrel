class Actor implements HasPosition{
  //FIELDS
  PVector position;
  float acceleration;
  float speed;
  int userID;

  int sampleLength = 6; //number of frames to average
  float avgSpeed = 0;
  float avgAccel = 0;

  LinkedList<PVector> positions = new LinkedList<PVector>();
  LinkedList<PVector> velocities = new LinkedList<PVector>();
  LinkedList<Float> speeds = new LinkedList<Float>();
  LinkedList<Float> accelerations = new LinkedList<Float>();


  //CONSTRUCTOR
  public Actor(PVector p) {
    //TODO: create link of some sort between game user and kinect user
    // and get the ability to access the points belonging to the user
    // in order to calculate size of user and amount of arm movement
    position = p;
    positions.add(p);

  }

  //METHODS
  public void setPosition(PVector p) {

  //TODO: convert values to m/s(m/s2)? - multiply by 1000/30 = 33.333 In any case: determine typical values and useful thresholds
  //TODO: improve filtering? Extend memory? Or add weighting?
  //TODO: make sure this function is called every frame, even if there is no change in position. 

    //Update position and store in list
    position = p;
    positions.add(new PVector(p.x, p.y, p.z));
    int lastPosition = positions.size()-1;
    if(lastPosition >1){
      //Calculate velocity (distance traveled in the last 1/30 second) and store in list
      PVector velocity = PVector.sub(positions.get(lastPosition), positions.get(lastPosition-1));
      velocities.add(velocity);

      //Calculate speed (magnitude of velocity) and store
      speed = velocity.mag();
      speeds.add(speed);
      if(speeds.size() > sampleLength){
        float speedSum = 0.0;
        speeds.removeFirst();
        for (Float s : speeds){
          speedSum += s;
        }
        avgSpeed = (speedSum/sampleLength);
        text(avgSpeed,40,40);
      }

      int lastSpeed = speeds.size()-1;
      if(lastSpeed >1){
        //Calculate acceleration (change in speed over the last 1/30 second) and store
        acceleration = speeds.get(lastSpeed)/speeds.get(lastSpeed-1);
        accelerations.add(acceleration);
        if(accelerations.size() > sampleLength){
          float accelSum = 0.0;
          accelerations.removeFirst();
          for (Float a : accelerations){
            accelSum += a;
          }
        avgAccel = (accelSum/sampleLength);
        text(avgAccel,40,80);
      }

      }
    }
  }

  public PVector getPosition() { 
    return position;
  }

  public float getSpeed() {
    return avgSpeed;
  }

  public float getAcceleration() {
    return avgAccel;
  }

  public int getUserID(){
    return userID;
  }

//TODO: find the size of the actor…

}

