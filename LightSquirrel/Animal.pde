class Animal{

//FIELDS
PVector position;
State state;
ArrayList<Relation> relationships; 
ArrayList<Light> lightsIKnow;
Box box;
float t = 0; //for calls to noise
float noiseRoughness =  0.05;
float noiseFactor = 10;
float maxSpeed = 100;

float energyLevel = 10;
float regenerate = 0.01;
float excitement = 5;

boolean fleeing = false; //is following "flee" script -
//While fleeing, ignores energy level, (but drains energy),
// ignores other users' mid-zone, but will trigger new flee if enters danger zone.
// If a flee is triggered consecutively from within flee state three times, the next flee will be aimed straight at a light, in order to hide.
//
boolean hiding = false; // state: hiding in box or light
//if energy level is at max level for longer than a given time without interruptions, animal will leave and begin moving about.
//can only leave box if lid is off. If in box and lid is lifted, go straight into flee mode.
Light hidingPlace;
boolean tired = false; //if true, getting to a light becomes first priority.
//Will try to avoid other users' danger zone. If flee is triggered while tired, head straight for light.
// Will hide in light if close enough. Can only hide in box if lid is open.


//CONSTRUCTOR
public Animal(PVector initialPosition){
	position = initialPosition;
	state = State.RESTING;
	relationships = new ArrayList<Relation>();
	lightsIKnow = new ArrayList<Light>();

}

//METHODS

public void createRelationship(Actor actor){
	relationships.add(new ActorRelation(actor, this));
	//create a new relationship and add it to the list
}

public void killRelationship(){
	//remove relationship from list
}

private void setMaxSpeed(float s){
	maxSpeed = s; //calculate from energylevel
}

private void updateEnergy(){
	if(energy <=10){
		energy += regenerate;
	}
	//refresh energy level
	//add or subtract energy based on movement
}

public void lookAround(){
	//check for new relationships, delete lost
	//update existing relationships
	//check for specific triggers
	//move
	act();

}

public void act(){
	//get movement vectors
	//move OR trigger/update scripted behaviour
	//make sound
	PVector move = getMovementVector();

	position.x += move.x;
	position.z += move.z;
}

public PVector getPosition() {
    return position;
}

private PVector getNoise(){
	PVector noiseComponent = new PVector(0,0,0);
        noiseComponent.x = map(noise(t), 0,1,-1,1);
        noiseComponent.y = map(noise(t+10000), 0,1,-1,1);
        noiseComponent.z = map(noise(t+20000), 0,1,-1,1);
	noiseComponent.setMag(noiseFactor);

	t += noiseRoughness;

	return noiseComponent;
}

private PVector getMovementVector(){
	PVector result = new PVector(0,0,0);
	for (Relation relation : relationships){
		if(relation.)
		result.add(relation.getResultVector());
	}

	result.add(getNoise());

	if(result.mag() > maxSpeed){
		result.setMag(maxSpeed);
	}

	return result;
}

}
