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
  

}