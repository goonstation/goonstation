/// Gravity force on this turf
/turf/var/effective_gforce = 1
/turf/space/effective_gforce = 0
/turf/space/fluid/effective_gforce = 1


// update gravity on simulated turf spawn
/turf/simulated/New()
	. = ..()
	src.reset_effective_gforce()

/// Recalculate the turf gravity based on area levels
/turf/proc/reset_effective_gforce()
	var/area/A = src.loc
	src.calculate_effective_gforce(A.gforce_minimum, A.gforce_tether)

/turf/space/reset_effective_gforce()
	src.effective_gforce = 0

/turf/space/fluid/reset_effective_gforce()
	var/area/A = src.loc
	src.calculate_effective_gforce(A.gforce_minimum, A.gforce_tether)

/turf/unsimulated/reset_effective_gforce()
	src.effective_gforce = 1

/// Set gravity on a turf
/turf/proc/calculate_effective_gforce(area_gravity, tether_gravity)
	return

/turf/simulated/calculate_effective_gforce(area_gravity, tether_gravity)
	if (contains_negative_matter(src))
		src.effective_gforce = 0
		return
	src.effective_gforce = src.get_gforce_minimum(area_gravity) + tether_gravity
	for (var/atom/movable/AM as anything in src)
		AM.set_gravity(src)

/turf/space/fluid/calculate_effective_gforce(area_gravity, tether_gravity)
	src.effective_gforce = src.get_gforce_minimum(area_gravity) + tether_gravity
	for (var/atom/movable/AM as anything in src)
		AM.set_gravity(src)

/// Get the minimum gforces to apply to this turf
/turf/proc/get_gforce_minimum(area_gforce_minimum=null)
	if (isnull(area_gforce_minimum))
		var/area/A = src.loc
		area_gforce_minimum = A.gforce_minimum
	. = max(global.zlevels[src.z]?.gforce, area_gforce_minimum, 0)

/turf/space/get_gforce_minimum(area_gforce_minimum=null)
	return 0

/turf/unsimulated/get_gforce_minimum(area_gforce_minimum=null)
	return 1

/turf/space/fluid/get_gforce_minimum(area_gforce_minimum=null)
	if (isnull(area_gforce_minimum))
		var/area/A = src.loc
		area_gforce_minimum = A.gforce_minimum
	. = max(global.zlevels[src.z]?.gforce, area_gforce_minimum, 0)

// asteroid turfs always have enough gravity for partial traction
/turf/simulated/floor/plating/airless/asteroid/get_gforce_minimum(area_gforce_minimum=null)
	return max(..(area_gforce_minimum), TRACTION_GFORCE_PARTIAL)
/turf/simulated/wall/auto/asteroid/get_gforce_minimum(area_gforce_minimum=null)
	return max(..(area_gforce_minimum), TRACTION_GFORCE_PARTIAL)

// airbridges on station Z get station tether gravity
/turf/simulated/floor/airbridge/get_gforce_minimum(area_gforce_minimum=null)
	if (src.z == Z_LEVEL_STATION)
		return max(..(area_gforce_minimum), global.station_tether_gforce)
	return ..(area_gforce_minimum)

/turf/simulated/wall/airbridge/get_gforce_minimum(area_gforce_minimum=null)
	if (src.z == Z_LEVEL_STATION)
		return max(..(area_gforce_minimum), global.station_tether_gforce)
	return ..(area_gforce_minimum)
