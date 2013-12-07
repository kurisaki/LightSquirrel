class Animal implements HasPosition {

//CONSTANTS
	static final int HIDE_THRESHOLD = 3000;
		// TIRED: getting to a light becomes first priority.
		// Will try to avoid other users' danger zone. If flee is triggered while tired, head straight for light.
		// Will hide in light if close enough. Can only hide in box if lid is open.
	static final int RUN_THRESHOLD = 5000;

	static final float NOISE_ROUGHNESS = 0.05;

//FIELDS
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

	float t = 0; //counter for calls to noise
	
	float noiseFactor = 10; //Degree of influence of noise

	float maxSpeed = 50;
	float minSpeed = 1;

	float excitement = 5; //general level of excitement - connected to pulse and sound speed.

	Light hidingPlace; //currently hiding 

	Room room;

//CONSTRUCTOR
	public Animal(PVector initialPosition, Room aRoom){
		position = initialPosition;
		state = State.HIDING;
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

		if (energy < HIDE_THRESHOLD) {
			hide();
		} else if (energy < RUN_THRESHOLD) {
			run();
		} else {
			explore();
		}
		Wall currentWall = room.getWall(position);
		position.add(moveVector);
		if(currentWall != Wall.NONE){
			position = room.projectOnWall(position, currentWall);
		}
	//TODO: make sound
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

		moveVector.add(room.getBounceVector(position));

		moveVector.add(getNoise());

		float maxSpeed = getMaxSpeed();
		moveVector.limit(maxSpeed);
	}

	void updateEnergy(){
	//TODO: refresh energy, more if resting.
	//add or subtract energy based on movement
	}

	void flee() {

	}
	void hide() {
	//TODO
	}

	void run() {
	//TODO
	}

	void explore() {

	}

	float getMaxSpeed(){
		//TODO: calculate based on energy
		return maxSpeed;
	}

	float getMinSpeed(){
		return minSpeed;
	}

	public PVector getPosition() {
		return position;
	}

	void setState(State aState){
		state = aState;
	}

	State getState(){
		return state;
	}

	private PVector getNoise(){
		PVector noiseComponent = new PVector(0,0,0);
		noiseComponent.x = map(noise(t), 0,1,-1,1);
		//noiseComponent.y = map(noise(t+10000), 0,1,-1,1);
		noiseComponent.z = map(noise(t+20000), 0,1,-1,1);
		noiseComponent.setMag(noiseFactor);

		t += NOISE_ROUGHNESS;

		return noiseComponent;
	}

        List<ActorRelation> getRelationships(){
          return relationships;
        }

	@Override
	public String toString() {
		return String.format("x: %f, z: %f, y: %f", position.x, position.z, position.y);
	}
}
