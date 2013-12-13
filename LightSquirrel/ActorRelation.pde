class ActorRelation{

	//CONSTANTS
	static final float MIN_ATTITUDE = -10;
	static final float MAX_ATTITUDE = 10;

	static final int MAX_FACTOR = 10;
	static final int MIN_FACTOR = 1;

	static final int DANGER_MIN = 300;
	static final int DANGER_MAX = 1000;

	static final int INTEREST_MIN = 2000;
	static final int INTEREST_MAX = 2000;

	//FIELDS
	Actor actor;
	Animal animal;
	float attitude;
	int interest;

	//CONSTRUCTOR
	public ActorRelation(Actor anActor, Animal anAnimal){
		actor = anActor;
		animal = anAnimal;
		attitude = 0;
		interest = 0;
	}

	float getInterestRadius(){
		return (INTEREST_MIN-INTEREST_MAX) * getNormalizedAttitude() + INTEREST_MAX;
	}

	float getDangerRadius(){
		return (DANGER_MIN-DANGER_MAX) * getNormalizedAttitude() + DANGER_MAX;
	}

	float getNormalizedAttitude(){
		float normalizedAttitude = (attitude - MIN_ATTITUDE ) / (float) (MAX_ATTITUDE - MIN_ATTITUDE);
		return normalizedAttitude;
	}

	PVector getReactionVector(){
		//Copy animal position
		PVector reaction = animal.getPosition().get();
		//Get direction to actor
		PVector projectedOnFloor = projectOnFloor(actor.getPosition());
		reaction.sub(projectedOnFloor);

		//React according to attitude
		float dangerRadius = getDangerRadius();
		float safeRadius = getInterestRadius();

		float distance = reaction.mag();
		if(distance < dangerRadius){
			animal.flee(actor.getPosition());
		} else if(distance < safeRadius){

			float x = distance - dangerRadius;
			float safeZone = safeRadius - dangerRadius;
			float speedFactor = (1 - x / safeZone);

			if(attitude > 0)
			{
				speedFactor = (0.9 - speedFactor);
			}

			reaction.setMag(speedFactor);
		} else {
			reaction.setMag(0);
		}

		reaction.mult(-attitude);

		return reaction;
	}

	void updateAttitude(){
		//TESTING

		if(true){
		//END TESTING


			final float SPEED_THRESHOLD = 30;
			final float ACCELERATION_THRESHOLD = 30;

			float speed = actor.getSpeed();
			float acceleration = actor.getAcceleration();

		//Update attitude based on speed and acceleration of actor
		//TODO: Make more complex implementation, e.g. startle
			if(speed > SPEED_THRESHOLD || acceleration > ACCELERATION_THRESHOLD){
				if(attitude > MIN_ATTITUDE){
					attitude-=0.5;
				}
			} else {
				if(attitude < MAX_ATTITUDE){				
					attitude+= 0.1;
				}
			}

		}

		text("Attitude: " + attitude, 10, 70);
	}

	Actor getActor(){return actor;}

}
