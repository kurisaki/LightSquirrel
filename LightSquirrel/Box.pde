class Box{

//FIELDS

final PVector position = new PVector(0,0,0); // ORIGO!
Light boxLight;
int openState; //0=closed, 1=half open, 2=full open

//CONSTRUCTOR
public Box(){
	boxLight = new Light(position);
	openState = 0;
}

//METHODS

public void setState(int aState){
	openState = aState;
}

public Light getLight(){
	return boxLight;
}

public PVector getPosition(){ return position ; }
}

