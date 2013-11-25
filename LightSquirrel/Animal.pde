class Animal{

//FIELDS
PVector position;
State state;
ArrayList<ActorRelation> relationships; 
ArrayList<Light> lightsThatIKnow;
Box box;
int pulse;

//CONSTRUCTOR
public Animal(PVector initialPosition){
	position = initialPosition;
	state = State.RESTING;
	relationships = new ArrayList<ActorRelation>();

}

//METHODS

public void lookAround(){
	for (ActorRelation relation : relationships){

	}

	//move
	float x = random(-10, 10);
	float z = random(-10, 10);

	position.x += x;
	position.z += z;
}

public PVector getPosition() {
    return position;
}

}
