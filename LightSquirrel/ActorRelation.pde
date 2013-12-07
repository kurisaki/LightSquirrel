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
	int dangerRadius;
	int safeRadius;

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
		PVector projectedOnFloor = projectOnFloor(actor.getPosition());
		reaction.sub(projectedOnFloor);

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

}
