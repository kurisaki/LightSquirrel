class Animal {

	//FIELDS
	PVector position;
	State state;
	ArrayList<ActorRelation> relationships; 
	ArrayList<Light> lightsThatIKnow;
	Box box;
	int energy = 10000;

	//CONSTRUCTOR
	public Animal(PVector initialPosition){
		position = initialPosition;
		state = State.RESTING;
		relationships = new ArrayList<ActorRelation>();

	}

	//METHODS
	public void update()
	{
		move();
	}

	void move() {
		PVector move = new PVector(0, 0, 0);
		for (ActorRelation relation : relationships){
			PVector vector = relation.getReactionVector();
			move.add(vector);
		}

		float maxSpeed = getMaxSpeed();
		move.limit(maxSpeed);

		position.add(move);
	}


	float getMaxSpeed(){
		//TODO: calculate based on energy
		return 1000;
	}

	public PVector getPosition() {
		return position;
	}

}
