#define SOUTHWEST_UNIQUE (1<<6)
#define NORTHWEST_UNIQUE (1<<7)
#define SOUTHEAST_UNIQUE (1<<8)
#define NORTHEAST_UNIQUE (1<<9)

#define CLOCKWISE 1
#define COUNTERCLOCKWISE -1

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

/// Gets the reverse direction of the direction given. SOUTH returns NORTH, SOUTHEAST returns NORTHWEST, etc.
/proc/reverse_dir(dir)
    if(dir & (NORTH|SOUTH))
        dir ^= (NORTH|SOUTH)
    if(dir & (EAST|WEST))
        dir ^= (EAST|WEST)
    return dir

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

/// Gives an atom an offset around a directed edge
proc/randomize_edge_offset(atom/target, dir, max_variation = 8, edge_offset = 13)
	var/pixel_x = 0
	var/pixel_y = 0

	if(dir & NORTH)
		pixel_y = edge_offset
	else if(dir & SOUTH)
		pixel_y = -edge_offset

	if(dir & EAST)
		pixel_x = edge_offset
	else if(dir & WEST)
		pixel_x = -edge_offset

	if(dir & (NORTH|SOUTH))
		pixel_x += rand(-max_variation, max_variation)
	else if(dir & (EAST|WEST))
		pixel_y += rand(-max_variation, max_variation)
	else
		pixel_x += rand(-max_variation, max_variation) * 0.7
		pixel_y += rand(-max_variation, max_variation) * 0.7

	pixel_x = clamp(pixel_x, -edge_offset, edge_offset)
	pixel_y = clamp(pixel_y, -edge_offset, edge_offset)

	target.pixel_x = pixel_x
	target.pixel_y = pixel_y

/// Given a starting direction, returns the best rotation direction towards the angle
proc/get_shortest_rotation(angle, starting_dir)
	var/start_angle = dir_to_angle(starting_dir)
	var/clockwise_diff = (angle - start_angle)
	if(clockwise_diff < 0)
		clockwise_diff += 360
	if(clockwise_diff > 180)
		return CLOCKWISE
	else
		return COUNTERCLOCKWISE

/// Searches rotationally around the given turf and returns the first passable turf found, checking the given direction first.
/// If no passable turf is found, returns the turf in the given direction.
proc/get_adjacent_passable(var/turf/turf, dir, clockwise)
	var/turf/endturf = get_step(turf, dir)
	var/step = 1
	var/test_dir = dir
	while (!checkTurfPassable(endturf) && step < 8)
		test_dir = turn(dir, (45 * clockwise * step))
		endturf = get_step(turf, test_dir)
		step++
	return endturf

/// Calculates the angle you need to pass to the turn proc to get dir_to from dir_from
/// turn(dir, turn_needed(dir, dir_to)) = dir_to
#define turn_needed(dir_from, dir_to) (-(dir_to_angle(dir_to) - dir_to_angle(dir_from)))
// note that the - is necessary because dir_to_angle returns a clockwise angle, but turn() takes a counter-clockwise angle

/// BYOND's default get_step_rand() is not actually uniformly random (heavily biased towards dir).
/// This is a replacement that is actually uniformly random.
#define get_step_truly_rand(O) get_step(O, pick(alldirs))

/// Returns a tile in a random cardinal direction
#define get_step_rand_cardinal(O) get_step(O, pick(cardinal))
