class Animal implements HasPosition {

  //CONSTANTS
  static final int HIDE_THRESHOLD = 3000;
  // TIRED: getting to a light becomes first priority.
  // Will try to avoid other users' danger zone. If flee is triggered while tired, head straight for light.
  // Will hide in light if close enough. Can only hide in box if lid is open.
  static final int RUN_THRESHOLD = 5000;

  static final float NOISE_ROUGHNESS = 0.05;

  //FIELDS
  Light targetLight = null;
  PVector position;
  PVector moveVector;
  State state;
  // FLEEING: is following "flee" script -
  // While fleeing, ignores energy level, (but drains energy),
  // ignores other users' mid-zone, but will trigger new flee if enters danger zone.
  // If a flee is triggered from within flee state three consecutive times, the next flee will be aimed straight at a light, in order to hide.
  // HIDING: unmoving in box or light
  // if energy level is at max level for longer than a given time without interruptions, animal will leave and begin moving about.
  // can only leave box if lid is off. If in box and lid is lifted, go straight into flee mode.
  // AVOIDING: amble around, but try to avoid users
  // INVESTIGATING: approach the friendly user with the highest interest, or some optimal combination of attitude and interest
  // (if tired, value attitude over interest? :-) )

  ArrayList<ActorRelation> relationships; 
  ArrayList<Light> lightsThatIKnow;
  Box box;

  int energy = 10000;
  int maxEnergy = 10000;

  float t = 0; //counter for calls to noise

  float noiseFactor = 5; //Degree of influence of noise

  float maxSpeed = 50;
  float minSpeed = 1;

  static final float FLEE_SPEED = 100;

  float excitement = 5; //general level of excitement - connected to pulse and sound speed.

  boolean isInLight = true;

  static final int FLEE_COUNT = 30;
  PVector fleeDirection;
  int fleeCountdown = 0;

  Room room;

  //CONSTRUCTOR
  public Animal(PVector initialPosition, Room aRoom) {
    position = initialPosition;
    state = State.ROAMING;
    relationships = new ArrayList<ActorRelation>();
    lightsThatIKnow = new ArrayList<Light>();
    this.room = aRoom;
  }


  //METHODS
  public void createRelationship(Actor actor) {
    relationships.add(new ActorRelation(actor, this));
    //create a new relationship and add it to the list
  }

  public void killRelationship() {
    //TODO: remove relationship from list
  }

  public void discoverLight(Light aLight) {
    lightsThatIKnow.add(aLight);
  }

  public void update() {
    updateRelations();
    updateMoveVector();

    text("State: " + state, 500, 10);

    if (energy < HIDE_THRESHOLD && state != State.FLEEING) {
      state = State.HIDING;
    } 
    else if (state != State.FLEEING && state != State.HIDING) {
      state = State.ROAMING;
    }
    Wall currentWall = room.getWall(position);
    position.add(moveVector);
    energy -= moveVector.mag();
    text("Energy: ", 10, 200);
    text(energy, 200, 200);
    if (currentWall != Wall.NONE) {
      position = room.projectOnWall(position, currentWall);
    }
    //TODO: make sound
  }																																												

  void updateRelations() {
    for (ActorRelation relation : relationships) {
      relation.updateAttitude();
    }
  }

  void updateMoveVector() {
    moveVector = new PVector(0, 0, 0);

    switch (state) {
    case FLEEING:
      moveVector.add(fleeDirection);
      moveVector.mult(FLEE_SPEED);
      fleeCountdown--;
      if (fleeCountdown == 0) {
        state = State.ROAMING;
      }

      break;

    case ROAMING:
      for (ActorRelation relation : relationships) {
        PVector vector = relation.getReactionVector();
        moveVector.add(vector);
      }
      moveVector.add(room.getBounceVector(position));
      moveVector.add(getNoise());

      moveVector.limit(maxSpeed);
      break;

    case HIDING:
      float lightDistance = 10000;
      //determine closest light and distance to it
      for (int i=0; i<lightsThatIKnow.size(); i++) {
        PVector lightPosition = lightsThatIKnow.get(i).getPosition();
        float temp;
        temp = PVector.sub(position, lightPosition).mag();
        if (temp<lightDistance) {
          targetLight = lightsThatIKnow.get(i);
          lightDistance = temp;
        }
      }
      if (lightDistance >= 10) {
        moveVector.add(targetLight.getReactionVector(position));
        for (ActorRelation relation : relationships) {
          PVector vector = relation.getReactionVector();
          moveVector.add(vector);
        }
        moveVector.add(room.getBounceVector(position));
        moveVector.limit(FLEE_SPEED);
      } 
      else if (lightDistance < 10 && !targetLight.isTouched()) {
          isInLight = true;
          targetLight.setState(1);
          spotlight.setState(0);
          if(energy<maxEnergy){
            energy +=100;
          }

        //else if target light IS touched
        //state = State.FLEEING
        //servoPort.write("<setSpotState," + 1 + ">"); 
        //lightPort.write("<set1State," + 0 + ">"); 
        //lightPort.write("<set2State," + 0 + ">");
      } else if(lightDistance < 10 && targetLight.isTouched()){
        PVector scaryPosition = relationships.get(0).getActor().getPosition();
        flee(scaryPosition);
      }
      
      //if distance to target light < threshold, enter light.
      //if hiding and in light, do nothing, unless touched. 
      //if touched, enter flee.
      break;
    }
  }

  void updateEnergy() {
    //TODO: refresh energy, more if resting.
    //add or subtract energy based on movement
  }

  void flee(PVector scaryPos) {
    spotlight.setState(1);
    state = State.FLEEING;
    fleeCountdown = FLEE_COUNT;
    fleeDirection = PVector.sub(position, scaryPos);
    fleeDirection.normalize();
  }


void roam() {
  state = State.ROAMING;
}

void hide() {
  state = State.HIDING;
}

float getMaxSpeed() {
  //TODO: calculate based on energy
  return maxSpeed;
}

float getMinSpeed() {
  return minSpeed;
}

public PVector getPosition() {
  return position;
}

void setState(State aState) {
  state = aState;
}

State getState() {
  return state;
}

private PVector getNoise() {
  PVector noiseComponent = new PVector(0, 0, 0);
  noiseComponent.x = map(noise(t), 0, 1, -1, 1);
  //noiseComponent.y = map(noise(t+10000), 0,1,-1,1);
  noiseComponent.z = map(noise(t+20000), 0, 1, -1, 1);
  noiseComponent.setMag(noiseFactor);

  t += NOISE_ROUGHNESS;

  return noiseComponent;
}

public List<ActorRelation> getRelationships() {
  return relationships;
}

@Override
public String toString() {
  return String.format("x: %f, z: %f, y: %f", position.x, position.z, position.y);
}

}

