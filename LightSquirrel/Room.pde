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
  	
    float distanceToCeiling = yHeight - vector.y;
    if(distanceToCeiling < BOUNCE_THRESHOLD){
      bounce.y = -(BOUNCE_THRESHOLD - distanceToCeiling) * bounceFactor;
    }
    return bounce;
  }

  Wall getWall(PVector vector3d){
    int halfX = xWidth / 2;
    int halfZ = zDepth / 2;
    if(vector3d.x >= halfX)
      return Wall.EAST;
    if(vector3d.x <= -halfX)
      return Wall.WEST;
    if(vector3d.z >= halfZ)
      return Wall.SOUTH;
    if(vector3d.z <= -halfZ)
      return Wall.NORTH;
    return Wall.NONE;
  }

  PVector projectOnWall(PVector vector3d, Wall wall){
    int halfX = xWidth / 2;
    int halfZ = zDepth / 2;
    PVector projected = vector3d.get();
    switch (wall){
      case NORTH:
        projected.y += -vector3d.z - halfZ;
        projected.z = -halfZ;
        projected.x = constrain(projected.x, -halfX, halfX);
        if(projected.y < 0) {
          projected.z -= projected.y;
          projected.y = 0;
        }
        break;
      case SOUTH:
        projected.y += vector3d.z - halfZ;
        projected.z = halfZ;
        projected.x = constrain(projected.x, -halfX, halfX);
        if(projected.y < 0) {
          projected.z += projected.y;
          projected.y = 0;
        }
        break;
      case EAST:
        projected.y += vector3d.x - halfX;
        projected.x = halfX;
        projected.z = constrain(projected.z, -halfZ, halfZ);
        if(projected.y < 0) {
          projected.x += projected.y;
          projected.y = 0;
        }
        break;
      case WEST:
        projected.y += -vector3d.x - halfX;
        projected.x = -halfX;
        projected.z = constrain(projected.z, -halfZ, halfZ);
        if(projected.y < 0) {
          projected.x -= projected.y;
          projected.y = 0;
        }
        break;
    }
    return projected;
  }

  PVector limitToFloor(PVector vector3d){
    int halfX = xWidth / 2;
    int halfZ = zDepth /2;
    int margin = 100;
    PVector limited = vector3d.get();
    limited.x = constrain(limited.x, -halfX + margin, halfX - margin);
    limited.z = constrain(limited.z, -halfZ + margin, halfZ - margin);
    return limited;
  }

}