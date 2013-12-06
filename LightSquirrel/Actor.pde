class Actor {
  //FIELDS
  PVector position;
  float acceleration;
  float speed;

  LinkedList<PVector> history = new LinkedList<PVector>();
  LinkedList<Float> speedHistory = new LinkedList<Float>();

  LinkedList<PVector> positions = new LinkedList<PVector>();
  LinkedList<PVector> velocities = new LinkedList<PVector>();
  LinkedList<Float> speeds = new LinkedList<Float>();
  LinkedList<Float> accelerations = new LinkedList<Float>();


  //CONSTRUCTOR
  public Actor(PVector p) {
    position = p;
    positions.add(p);

  }

  //METHODS
  public void setPosition(PVector p) {

  //TODO: convert values to m/s(m/s2)? 
  //TODO: add some kind of filtering (median) or averaging over time
  //TODO: make sure this function is called every frame, even if there is no change in position. 

    //Update position and store in list
    position = p;
    positions.add(new PVector(p.x, p.y, p.z));
    textSize(24);
    fill(255);

    int lastPosition = positions.size()-1;
    if(lastPosition >1){
      //Calculate velocity (distance traveled in the last 1/30 second) and store in list
      PVector velocity = PVector.sub(positions.get(lastPosition), positions.get(lastPosition-1));
      velocities.add(velocity);

      //Calculate speed (magnitude of velocity) and store
      speed = velocity.mag();
      speeds.add(speed);

      int lastSpeed = speeds.size()-1;
      if(lastSpeed >1){
        //Calculate acceleration (change in speed over the last 1/30 second) and store
        acceleration = speeds.get(lastSpeed)/speeds.get(lastSpeed-1);
        accelerations.add(acceleration);

      }
    }
  }

  public PVector getPosition() { 
    return position;
  }

  public float getSpeed() {
    return speed;
  }

  public float getAcceleration() {
    return acceleration;
  }
}

