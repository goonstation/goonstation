#define SOUTHWEST_UNIQUE (1<<6)
#define NORTHWEST_UNIQUE (1<<7)
#define SOUTHEAST_UNIQUE (1<<8)
#define NORTHEAST_UNIQUE (1<<9)

/// Never Soggy Eat Waffles
var/global/list/cardinal = list(NORTH, SOUTH, EAST, WEST)
/// Diagonal directions
var/global/list/ordinal = list(NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST)
var/global/list/ordinal_unique = list(NORTHEAST_UNIQUE, SOUTHEAST_UNIQUE, SOUTHWEST_UNIQUE, NORTHWEST_UNIQUE)
/// Every direction known to 2D tile-grid-locked spessmen
var/global/list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST)
var/global/list/alldirs_unique = list(NORTH, SOUTH, EAST, WEST, NORTHEAST_UNIQUE, SOUTHEAST_UNIQUE, SOUTHWEST_UNIQUE, NORTHWEST_UNIQUE)
var/global/list/modulo_angle_to_dir = list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST)
/// Assoc. list of dirs like `"north"=NORTH`
var/global/list/dirnames = list("north"=NORTH, "south"=SOUTH, "east"=EAST, "west"=WEST, "northeast"=NORTHEAST, "southeast"=SOUTHEAST, "southwest"=SOUTHWEST, "northwest"=NORTHWEST)
/// Assoc. list of dirs like `"[NORTH]" = "NORTH"`, useful for screen_loc
var/global/list/dirvalues = list("[NORTH]" = "NORTH", "[SOUTH]" = "SOUTH", "[EAST]" = "EAST", "[WEST]" = "WEST", "[NORTHEAST]" = "NORTHEAST", "[SOUTHEAST]" = "SOUTHEAST", "[SOUTHWEST]" = "SOUTHWEST", "[NORTHWEST]" = "NORTHWEST")

/// Returns the lowercase english word for a direction (num)
/proc/dir_to_dirname(dir)
	return lowertext(global.dirvalues["[dir]"])

/// Returns the direction (num) of a given lowercase english direction
proc/dirname_to_dir(dirname)
	return global.dirnames[dirname]

/// Returns true if a direction is cardinal
#define is_cardinal(DIR) (!((DIR - 1) & DIR))

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

/// Checks if an angle is between two other angles
proc/angle_inbetween(angle, low, high)
	angle = ((angle % 360) + 360) % 360
	low = ((low % 360) + 360) % 360
	high = ((high % 360) + 360) % 360
	if(low > high)
		return (angle >= low || angle <= high)
	return (angle >= low && angle <= high)

/**
  * Transforms a given angle to vec2 in a list
  */
proc/angle_to_vector(ang)
	.= list()
	. += cos(ang)
	. += sin(ang)

/// Calculates the angle you need to pass to the turn proc to get dir_to from dir_from
/// turn(dir, turn_needed(dir, dir_to)) = dir_to
#define turn_needed(dir_from, dir_to) (-(dir_to_angle(dir_to) - dir_to_angle(dir_from)))
// note that the - is necessary because dir_to_angle returns a clockwise angle, but turn() takes a counter-clockwise angle

/// BYOND's default get_step_rand() is not actually uniformly random (heavily biased towards dir).
/// This is a replacement that is actually uniformly random.
#define get_step_truly_rand(O) get_step(O, pick(alldirs))

/// Returns a tile in a random cardinal direction
#define get_step_rand_cardinal(O) get_step(O, pick(cardinal))
