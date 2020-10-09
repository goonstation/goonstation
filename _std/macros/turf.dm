
/**
	* Returns the curent turf atom/x is on, through any number of nested layers
	*
	* See: http://www.byond.com/forum/?post=2110095
	*/
#define get_turf(x) get_step(x, 0)

/// Returns true if x is a simulated turf
#define issimulatedturf(x) istype(x, /turf/simulated)

/// Returns true if x is a floor type
#define isfloor(x) (istype(x, /turf/simulated/floor) || istype(x, /turf/unsimulated/floor))

/// Returns true if x is a reinforced wall
#define isrwall(x) (istype(x,/turf/simulated/wall/r_wall)||istype(x,/turf/simulated/wall/auto/reinforced)||istype(x,/turf/unsimulated/wall/auto/reinforced)||istype(x,/turf/simulated/wall/false_wall/reinforced))

