class Animal{

//FIELDS
PVector position;
State state;
ArrayList<ActorRelation> relationships; 
ArrayList<Light> lightsThatIKnow;
Box box;

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

}

}
