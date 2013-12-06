class ActorRelation extends Relation{

	//CONSTANTS
	static final int MIN_ATTITUDE = -10;
	static final int MAX_ATTITUDE = 10;
	static final int MIN_INTEREST = -10;
	static final int MAX_INTEREST = 10;

	//FIELDS
	Actor actor;
	Animal animal;
<<<<<<< HEAD
	int attitude; //-10 to +10
	int interest; // -10 to +10
=======
	int attitude;
	int interest;
>>>>>>> cf3cd9f56caba0b70cefdf0491e1bd725e9d3253
	int dangerRadius;
	int safeRadius;
    float speed = -20;


<<<<<<< HEAD
//CONSTRUCTOR
public ActorRelation(Actor actor, Animal animal){
	this.actor = actor;
	this.animal = animal;
	attitude = 0;
	interest = 0;
	dangerRadius = 1000;
	safeRadius = 2000;
}
=======
	//CONSTRUCTOR
	public ActorRelation(Actor anActor, Animal anAnimal){
		actor = anActor;
		animal = anAnimal;
		attitude = 0;
		interest = 0;
		dangerRadius = 1000;
		safeRadius = 2000;
	}
>>>>>>> cf3cd9f56caba0b70cefdf0491e1bd725e9d3253

	PVector getReactionVector(){
		//Copy animal position
		PVector reaction = animal.getPosition().get();
		//Get direction to actor
		reaction.sub(actor.getPosition());

		//React according to attitude
		reaction.normalize();
		reaction.mult(10 * attitude);

		return reaction;
	}

	void updateAttitude(){
		final float SPEED_THRESHOLD = 10;
		final float ACCELERATION_THRESHOLD = 10;

		float speed = actor.getSpeed();
		float acceleration = actor.getAcceleration();

		//Update attitude based on speed and acceleration of actor
		//TODO: Make more complex implementation, e.g. startle
		if(speed > SPEED_THRESHOLD || acceleration > ACCELERATION_THRESHOLD){
			if(attitude > MIN_ATTITUDE){
				attitude--;
			}
		} else {
			if(attitude < MAX_ATTITUDE){				
				attitude++;
			}
		}
	}

	void updateInterest(){
		//TOOD
	}

PVector getResultVector(){
	PVector something = PVector.sub(actor.getPosition(), animal.getPosition());

	float distance = something.mag();
	if(distance<dangerRadius){
		speed = -50;
	} else if (distance >=dangerRadius && distance < safeRadius){
		speed = -10;
	} else if (distance >= safeRadius){
		speed = 0;
	}
	something.setMag(speed);
	return something;
}

public void updateRelationship(){

}

}
