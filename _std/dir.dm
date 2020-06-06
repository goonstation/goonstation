var/global/list
	cardinal = list(NORTH, SOUTH, EAST, WEST)
	ordinal = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	modulo_angle_to_dir = list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST)


#define angle2dir(X) (modulo_angle_to_dir[round((((X%360)+382.5)%360)/45)+1])
