class Actor implements HasPosition{
  //FIELDS
  PVector position;
  float acceleration;
  float speed;
  float maxAccel;
  float maxSpeed;
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
    setPosition(p);
    //positions.add(p);

  }

  //METHODS
  public void setPosition(PVector p) {

  //TODO: convert values to m/s(m/s2)? - multiply by 1000/30 = 33.333 In any case: determine typical values and useful thresholds
  //TODO: improve filtering? Extend memory? Or add weighting?
  //TODO: make sure this function is called every frame, even if there is no change in position. 

    //Update position and store in list
    position = p;
    position.y = 0;
    positions.add(position.get());
    if(positions.size() > sampleLength){
      positions.removeFirst();
      //Calculate velocity (distance traveled in the last 1/30 second) and store in list
      PVector velocity = PVector.sub(positions.get(sampleLength-1), positions.get(sampleLength-2));
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
        avgSpeed = (speedSum / sampleLength);
        text("Speed: " + avgSpeed, 10, 40);
        maxSpeed = max(avgSpeed, maxSpeed);
        text("Max speed: " + maxSpeed, 10, 50);

        //Calculate acceleration (change in speed over the last 1/30 second) and store
        float lastSpeed = speeds.get(sampleLength-1);
        float prevSpeed = speeds.get(sampleLength-2);
        acceleration = prevSpeed > 0 ? lastSpeed / prevSpeed : 0;
        accelerations.add(acceleration);
        if(accelerations.size() > sampleLength){
          float accelSum = 0.0;
          accelerations.removeFirst();
          for (Float a : accelerations){
            accelSum += a;
          }
          avgAccel = (accelSum / sampleLength);
          text("Acceleration: " + avgAccel, 10, 80);
          maxAccel = max(avgAccel, maxAccel);
          text("Max acc.: " + maxAccel, 10, 90);
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

