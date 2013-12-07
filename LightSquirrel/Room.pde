class Room {
	//FIELDS
	int xWidth;
	int zDepth;
	int yHeight;
	//Presume square room/active area


	//CONSTRUCTOR
	public Room(int x, int z, int y){
	  xWidth = x;
	  zDepth = z;
	  yHeight = y;
	}


	//METHODS
  int getWidth(){ return xWidth; }
  int getDepth(){ return zDepth; }
  int getHeight() { return yHeight; }
  
  static final int BOUNCE_THRESHOLD = 300;

  PVector getBounceVector(PVector vector){
  	PVector bounce = new PVector();
  	float bounceFactor = 1;
  	//Assuming origo is in the middle of the room
  	int halfZ = zDepth / 2;
  	if (vector.z > halfZ - BOUNCE_THRESHOLD){
  		// Near "top" wall
  		bounce.z -= bounceFactor * (BOUNCE_THRESHOLD - (halfZ - vector.z));
  	} else if(vector.z < -halfZ + BOUNCE_THRESHOLD){
  		// Near "bottom" wall
  		bounce.z += bounceFactor * (BOUNCE_THRESHOLD -(vector.z - halfZ));
  	}

  	if (vector.y > yHeight - BOUNCE_THRESHOLD){
  		// Near ceiling
  		bounce.y -= bounceFactor * (BOUNCE_THRESHOLD - (yHeight - vector.y));
  	}
  	return bounce;
  }
}