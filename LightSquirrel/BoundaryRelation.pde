class BoundaryRelation extends Relation{

//FIELDS
	Actor actor;
	int attitude; //-10 to +10
	int interest; // -10 to +10
	int dangerRadius;
	int safeRadius;

//CONSTRUCTOR
public BoundaryRelation(Actor target){
	actor = target;
	attitude = 0;
	interest = 0;
	dangerRadius = 1000;
	safeRadius = 2000;
}

PVector getResultVector(){
	PVector something = new PVector(0,0,0);
	return something;
}

}
