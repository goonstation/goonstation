var/global/list
	cardinal = list(NORTH, SOUTH, EAST, WEST)
	ordinal = list(NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST)
	alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST)
	modulo_angle_to_dir = list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST)

/// Given an angle, matches it to the closest direction and returns it.
#define angle2dir(X) (modulo_angle_to_dir[round((((X%360)+382.5)%360)/45)+1])

/**
  * Returns the vector magnitude of an x value and a y value
  */
proc/vector_magnitude(x,y)
	//can early out
	.= sqrt(x*x + y*y);

/**
  * Transforms a supplied vector x & y to a direction
  */
proc/vector_to_dir(x,y)
	.= angle_to_dir(arctan(y,x))

/**
  * Transforms a given angle to a cardinal/ordinal direction
  */
proc/angle_to_dir(angle)
	.= 0
	if (angle >= 360)
		return angle_to_dir(angle-360)
	if (angle >= 0)
		if (angle < 22.5)
			.= NORTH
		else if (angle <= 67.5)
			.= NORTHEAST
		else if (angle < 112.5)
			.= EAST
		else if (angle <= 157.5)
			.= SOUTHEAST
		else
			.= SOUTH
	else if (angle < 0)
		if (angle > -22.5)
			.= NORTH
		else if (angle >= -67.5)
			.= NORTHWEST
		else if (angle > -112.5)
			.= WEST
		else if (angle >= -157.5)
			.= SOUTHWEST
		else
			.= SOUTH

/**
  * Transforms a cardinal/ordinal direction to an angle
  */
proc/dir_to_angle(dir)
	.= 0
	switch(dir)
		if(NORTH)
			.= 0
		if(NORTHEAST)
			.= 45
		if(EAST)
			.= 90
		if(SOUTHEAST)
			.= 135
		if(SOUTH)
			.= 180
		if(SOUTHWEST)
			.= 225
		if(WEST)
			.= 270
		if(NORTHWEST)
			.= 315

/**
  * Transforms a given angle to vec2 in a list
  */
proc/angle_to_vector(ang)
	.= list()
	. += cos(ang)
	. += sin(ang)
