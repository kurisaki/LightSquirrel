class WorldSound{

//FIELDS
	int roomWidth = 4000;
	int roomDepth = 4000;
	PVector soundOrigin = new PVector(0,0,0);
	float theta = 0.0;
	float r = 0.0;
	float maxRadius;
	//get info from room
	//get position of speakers

//CONSTRUCTOR
public WorldSound(){
	maxRadius = sqrt(roomWidth^2 + roomDepth^2);
}
//METHODS	
	//get position of sound, angle and distance, from X/Y coordinates.
	//OPTIONAL: optimize sound for user, i.e. move center of surround to the user…
	public void updatePosition(){
		//Determine angle and map to MIDI value
		theta = atan2(PVector.z, PVector.x);
		if(theta >= 0){
			theta = map(theta, 0, PI, 0, 127/2);
		} else if(theta < 0){
			theta = map(theta, -PI, 0, 127/2, 127);
		}
		//Determine diversity and map to MIDI value
		r = map(soundOrigin.mag(), 0, maxRadius, 0, 127);
	}

/*void MIDI(){ //examples of possible MIDI controllers for surround sound!
  int diversity = 127; //distance from center  
  myBus.sendControllerChange(0,25,diversity);
  int soundAngle = 0; //angle, clockwise
  myBus.sendControllerChange(0,24,soundAngle);

  MIDI CC 20-31 non-defined:

Channel  	CC 		Control
----------------------------------
0			24		SoundAngle
0			25		Diversity
0			26		Tempo (50-177 bpm, -> 100-354 double time)
0			27		High-pass filter (box)
0			28		Low-pass filter (wool)

}*/

}