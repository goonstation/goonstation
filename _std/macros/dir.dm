var/global/list
	cardinal = list(NORTH, SOUTH, EAST, WEST)
	ordinal = list(NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST)
	alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST)
	modulo_angle_to_dir = list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST)

/// Given an angle, matches it to the closest direction and returns it.
#define angle2dir(X) (modulo_angle_to_dir[round((((X%360)+382.5)%360)/45)+1])
