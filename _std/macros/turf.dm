
/**
	* Returns the curent turf atom/x is on, through any number of nested layers
	*
	* See: <http://www.byond.com/forum/?post=2110095>
	*/
#define get_turf(x) get_step(x, 0)

/// Gets the z-level of the turf an atom is on
#define get_z(x) get_step(x, 0)?.z

/// returns a list of all neighboring turfs in cardinal directions.
#define getneighbours(x) (list(get_step(x, NORTH), get_step(x, EAST), get_step(x, SOUTH), get_step(x, WEST)))

/// Returns true if x is a simulated turf
#define issimulatedturf(x) istype(x, /turf/simulated)

/// Returns true if x is a floor type
#define isfloor(x) (istype(x, /turf/simulated/floor) || istype(x, /turf/unsimulated/floor))

/// Returns true if x is a any kind of wall
#define iswall(x) (istype(x,/turf/simulated/wall)||istype(x,/turf/unsimulated/wall))

/// Returns true if x is a reinforced wall
#define isrwall(x) (istype(x,/turf/simulated/wall/r_wall)||istype(x,/turf/simulated/wall/auto/reinforced)||istype(x,/turf/unsimulated/wall/auto/reinforced)||istype(x,/turf/simulated/wall/false_wall/reinforced))

#define wall_window_check(x) (isturf(x) && (istypes(x, list(/turf/simulated/wall/auto, /turf/unsimulated/wall/auto) || (locate(/obj/mapping_helper/wingrille_spawn) in x) || (locate(/obj/window) in x))))

/**
	* Creates typepaths for an unsimulated turf, a simulated turf, an airless simulated turf, and an airless unsimulated turf at compile time.
	*
	* `_PATH` should be an incomplete typepath like `purple/checker` or `orangeblack/side/white`
	*
	* It will automatically be formatted into a correct typepath, like `/turf/simulated/floor/purple/checker`
	*
	* `_VARS` should be variables/values that the defined type should have.
	*
	* It should be formatted like:
	*
	*```
	*	foo = 1\
	*	bar = "baz")
	*```
	*
	* EXAMPLE USAGES:
	*
	*```
	*	DEFINE_FLOORS(orangeblack/side/white,
	*		icon_state = "cautionwhite")
	*```
	*
	*```
	*	DEFINE_FLOORS(damaged1,
	*		icon_state = "damaged1";\
	*		step_material = "step_plating";\
	*		step_priority = STEP_PRIORITY_MED)
	*```
	*
	* NOTE: this macro isnt for every situation. if you need to define some procs on a turf, don't use this
	* macro and make sure to mirror your changes across turf/floors_airless.dm, turf/floors_unsimulated.dm
	* and turf/floors.dm.
	*/
#define DEFINE_FLOORS(_PATH, _VARS) \
	/turf/simulated/floor/_PATH{_VARS};\
	/turf/unsimulated/floor/_PATH{_VARS};\
	/turf/simulated/floor/airless/_PATH{_VARS};\
	/turf/unsimulated/floor/airless/_PATH{_VARS};

/// Creates typepaths for a `/turf/simulated/floor/_PATH` and a `/turf/simulated/floor/airless/_PATH` with vars from `_VARS`
#define DEFINE_FLOORS_SIMMED(_PATH, _VARS) \
	/turf/simulated/floor/_PATH{_VARS};\
	/turf/simulated/floor/airless/_PATH{_VARS};

/// Creates typepaths for a `/turf/unsimulated/floor/_PATH` and a `/turf/unsimulated/floor/airless/_PATH` with vars from `_VARS`
#define DEFINE_FLOORS_UNSIMMED(_PATH, _VARS) \
	/turf/unsimulated/floor/_PATH{_VARS};\
	/turf/unsimulated/floor/airless/_PATH{_VARS};

/// Creates typepaths for a `/turf/simulated/floor/_PATH` and a `/turf/unsimulated/floor/_PATH` with vars from `_VARS`
#define DEFINE_FLOORS_SIMMED_UNSIMMED(_PATH, _VARS) \
	/turf/simulated/floor/_PATH{_VARS};\
	/turf/unsimulated/floor/_PATH{_VARS};\

/// Creates typepaths for a `/turf/simulated/floor/airless/_PATH` and a `/turf/unsimulated/floor/airless/_PATH with vars` from `_VARS`
#define DEFINE_FLOORS_AIRLESS(_PATH, _VARS) \
	/turf/simulated/floor/airless/_PATH{_VARS};\
	/turf/unsimulated/floor/airless/_PATH{_VARS};

/// Creates a typepath for a `/turf/simulated/floor/_PATH` with vars from `_VARS`
#define DEFINE_FLOOR_SIMMED(_PATH, _VARS) \
	/turf/simulated/floor/_PATH{_VARS};

/// Creates a typepath for a /turf/unsimulated/floor/_PATH with vars from _VARS
#define DEFINE_FLOOR_UNSIMMED(_PATH, _VARS) \
	/turf/unsimulated/floor/_PATH{_VARS};

/// Creates a typepath for a /turf/simulated/floor/airless/_PATH with vars from _VARS
#define DEFINE_FLOOR_SIMMED_AIRLESS(_PATH, _VARS) \
	/turf/simulated/floor/airless/_PATH{_VARS};

/// Creates a typepath for a /turf/unsimulated/floor/airless/_PATH with vars from _VARS
#define DEFINE_FLOOR_UNSIMMED_AIRLESS(_PATH, _VARS) \
	/turf/unsimulated/floor/airless/_PATH{_VARS};
