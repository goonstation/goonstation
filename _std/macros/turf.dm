// get_step() with a dir of 0 just gets the turf an atom is on, through any number of nested layers.
// See: http://www.byond.com/forum/?post=2110095
#define get_turf(x) get_step(x, 0)
#define issimulatedturf(x) istype(x, /turf/simulated)
#define isfloor(x) (istype(x, /turf/simulated/floor) || istype(x, /turf/unsimulated/floor))
#define isrwall(x) (istype(x,/turf/simulated/wall/r_wall)||istype(x,/turf/simulated/wall/auto/reinforced)||istype(x,/turf/unsimulated/wall/auto/reinforced)||istype(x,/turf/simulated/wall/false_wall/reinforced))
#define getneighbours(x) (list(get_step(x, NORTH), get_step(x, EAST), get_step(x, SOUTH), get_step(x, WEST)))