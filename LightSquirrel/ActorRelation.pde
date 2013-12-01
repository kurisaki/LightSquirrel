class ActorRelation{

//FIELDS
	Actor actor;
	int attitude; //-10 to +10
	int interest; // -10 to +10
	int dangerRadius;
	int safeRadius;

//CONSTRUCTOR
public ActorRelation(Actor target){
	actor = target;
	attitude = 0;
	interest = 0;
	dangerRadius = 1000;
	safeRadius = 2000;
}

Actor getActor(){
	return actor;
}

int getAttitude(){
	return attitude;
}

int getInterest(){
	return interest;
}

int getDangerRadius(){
	return dangerRadius;
}

int getSafeRadius(){
	return safeRadius;
}

PVector getReactionVector(PVector animalPosition){
	PVector reaction = new PVector(0,0,0);

	

	return reaction;
}


}
