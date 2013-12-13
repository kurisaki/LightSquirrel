class Light implements HasPosition {

//FIELDS
PVector position;
int state;	//0=off, 1=on, 2=breathe
int frequency; //only applicable when breathing.
boolean isAvailable = true;
boolean isTouched = false;

//CONSTRUCTOR(S)
public Light(PVector p, int s, int f){
	position = p;
	state = s;
	frequency = f;
}

public Light(PVector p){
	position = p;
	state = 0;
	frequency = 3000;
}

//METHODS
public void setState(int aState){
	state = aState;
}	
public int getState(){ return state; }

public void setAvailable(boolean available){
	isAvailable = available;
}

public boolean isAvailable(){
	return isAvailable;
}

public boolean isTouched(){
  return isTouched;
}

public void setTouched(int i){
  if (i == 1){
    isTouched = true;
    state = 0;
  } else {
    isTouched = false;
  }  
}

public void setFrequency(int aFrequency){
	frequency = aFrequency;
}

public PVector getPosition(){ return position; }

public PVector getReactionVector(PVector target){
	PVector reactionVector = PVector.sub(this.position, target);
	reactionVector.normalize();
        reactionVector.setMag(10);
	return reactionVector;
}

}


