PVector projectOnFloor(PVector vec3d){
	PVector projected = vec3d.get();
	projected.y = 0;
	return projected;
}