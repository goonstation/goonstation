/// Amount of gravity on the station Z-level
var/global/z_level_station_gravity = 0

#ifdef UNDERWATER_NAP
global.z_level_station_gravity = 1
#endif

/// Amount of gravity on this specific turf
/turf/var/effective_gravity = 1

/turf/space/effective_gravity = 0
/turf/space/fluid/effective_gravity = 1

/turf/simulated/New()
	. = ..()
	src.update_gravity()

/// Reset turf gravity based on area and composition
/turf/proc/update_gravity()
	if (contains_negative_matter(src))
		src.set_gravity(0)
		return

	var/area/A = get_area(src)
	if (istype(A))
		src.set_gravity(A.gravity_force)

/// Set gravity gforce on a turf and update mobs inside
/turf/proc/set_gravity(gforce)
	if (src.z == Z_LEVEL_STATION)
		gforce += global.z_level_station_gravity
	if (gforce != src.effective_gravity)
		src.effective_gravity = gforce
		for (var/mob/living/M in get_all_mobs_in(src))
			M.update_gravity(src.effective_gravity)

// space cannot have gravity
/turf/space/set_gravity(gforce)
	return

// inheritance skip
/turf/space/fluid/set_gravity(gforce)
	if (src.z == Z_LEVEL_STATION)
		gforce += global.z_level_station_gravity
	src.effective_gravity = gforce

// airbridges on station Z get station tether gravity applied
/turf/simulated/floor/airbridge/set_gravity(gforce)
	if (src.z == Z_LEVEL_STATION)
		gforce += global.get_station_gravity()
	. = ..(gforce)
/turf/simulated/wall/airbridge/set_gravity(gforce)
	if (src.z == Z_LEVEL_STATION)
		gforce += global.get_station_gravity()
	. = ..(gforce)

// asteroids always have a little gravity
/turf/simulated/floor/plating/airless/asteroid/set_gravity(gforce)
	if (src.z == Z_LEVEL_STATION)
		gforce += global.z_level_station_gravity
	gforce = max(gforce, 0.2)
	src.effective_gravity = gforce
/turf/simulated/wall/auto/asteroid/set_gravity(gforce)
	if (src.z == Z_LEVEL_STATION)
		gforce += global.z_level_station_gravity
	gforce = max(gforce, 0.2)
	src.effective_gravity = gforce
