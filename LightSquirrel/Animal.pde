class Animal {

	//CONSTANTS
	static final int SLEEP_THRESHOLD = 1000;
	static final int HIDE_THRESHOLD = 3000;
	static final int RUN_THRESHOLD = 5000;

	//FIELDS
	PVector position;
	State state;
	ArrayList<ActorRelation> relationships; 
	ArrayList<Light> lightsThatIKnow;
	Box box;
	int energy = 10000;
	PVector moveVector;
	int pulse;

	//CONSTRUCTOR
	public Animal(PVector initialPosition){
		position = initialPosition;
		state = State.RESTING;
		relationships = new ArrayList<ActorRelation>();

	}

	//METHODS
	public void update()
	{
		updateRelations();
		updateMoveVector();

		if(energy < SLEEP_THRESHOLD){
			sleep();
		} else if (energy < HIDE_THRESHOLD) {
			hide();
		} else if (energy < RUN_THRESHOLD) {
			run();
		} else {
			explore();
		}

		position.add(moveVector);
	}

	void updateRelations() {
		for (ActorRelation relation : relationships){
			relation.updateAttitude();
			relation.updateInterest();
		}
	}

	void updateMoveVector() {
		moveVector = new PVector(0, 0, 0);
		for (ActorRelation relation : relationships){
			PVector vector = relation.getReactionVector();
			moveVector.add(vector);
		}

		float maxSpeed = getMaxSpeed();
		moveVector.limit(maxSpeed);
	}

	void hide() {
		//TODO
	}

	void sleep(){
		//TODO
	}

	void run() {
		//TODO
	}

	void explore() {

	}

	float getMaxSpeed(){
		//TODO: calculate based on energy
		return 1000;
	}

	public PVector getPosition() {
		return position;
	}

}
