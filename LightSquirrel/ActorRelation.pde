class ActorRelation{

	//CONSTANTS
	static final int MIN_ATTITUDE = -10;
	static final int MAX_ATTITUDE = 10;
	static final int MIN_INTEREST = -10;
	static final int MAX_INTEREST = 10;

	//FIELDS
	Actor actor;
	Animal animal;

	int attitude;
	int interest;
	float currentRadius;
	float dangerRadius;
	float safeRadius;
    float speed = -20;



	//CONSTRUCTOR
	public ActorRelation(Actor anActor, Animal anAnimal){
		actor = anActor;
		animal = anAnimal;
		attitude = 0;
		interest = 0;
		dangerRadius = 1000;
		safeRadius = 2000;
	}

	PVector getReactionVector(){
		//Copy animal position
		PVector reaction = animal.getPosition().get();
		//Get direction to actor
		reaction.sub(actor.getPosition());
		//Get distance to actor
		currentRadius = reaction.mag();
		//React according to attitude
		reaction.normalize();
		if(currentRadius <= dangerRadius){
			reaction.mult(20 * attitude);
		} else if(currentRadius > dangerRadius && currentRadius <= safeRadius){
			float a = (animal.getMinSpeed() - animal.getMaxSpeed()/safeRadius);
			float f = a*(currentRadius-dangerRadius) + animal.getMaxSpeed();
			reaction.mult(f * attitude);
		} else if(currentRadius > safeRadius){
			reaction.mult(1 * attitude);		
		}
		return reaction;
	}

	void updateAttitude(){
		final float SPEED_THRESHOLD = 10;
		final float ACCELERATION_THRESHOLD = 10;

		float speed = actor.getSpeed();
		float acceleration = actor.getAcceleration();

		//TODO: (possibly) Update attitude based on speed and acceleration of actor
		//TODO: Make more complex implementation, e.g. startle
		//TODO: tweak settings for thresholds, and measure speed/acceleration over time…
		//In addition to decreasing attitude, acceleration over a panic threshold will trigger the flight response.
		//Positive modifiers for movement towards animal and proximity, negative modifier for movement away.
		
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


public void updateRelationship(){

}

}
