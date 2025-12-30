/// current gforce on this turf
/turf/var/gforce_current = 1
/// gforce inherent to the turf tile, e.g. asteroids and airbridges
/turf/var/gforce_inherent = 0

// no gravity in space
/turf/space/gforce_current = 0
/turf/space/gforce_inherent = 0

// ocean gravity handled at zlevel
/turf/space/fluid/gforce_current = 1
/turf/space/fluid/gforce_inherent = 0

/turf/proc/update_gforce_inherent(new_gforce)
/turf/simulated/update_gforce_inherent(new_gforce)
	if (new_gforce == src.gforce_inherent)
		return
	var/area/A = src.loc
	if (!istype(A))
		return
	src.gforce_inherent = new_gforce
	src.gforce_current = round(max(A.gforce_minimum, global.zlevels[src.z].gforce + A.gforce_tether + src.gforce_inherent), 0.01)

// asteroids have enough G for some traction (for mining)
/turf/simulated/wall/auto/asteroid/gforce_inherent = TRACTION_GFORCE_PARTIAL
/turf/unsimulated/floor/plating/asteroid/gforce_inherent = TRACTION_GFORCE_PARTIAL
/turf/simulated/floor/plating/airless/asteroid/gforce_inherent = TRACTION_GFORCE_PARTIAL

/turf/setMaterial(datum/material/mat1, appearance, setname, mutable, use_descriptors)
	. = ..()
	if (contains_negative_matter(src))
		src.update_gforce_inherent(-INFINITY) // *always* zero-G
	else if (src.gforce_inherent != initial(src.gforce_inherent))
		src.update_gforce_inherent(initial(src.gforce_inherent))

// update gravity on simulated turf spawn
/turf/simulated/New()
	. = ..()
	var/area/A = src.loc
	if (!istype(A))
		return
	src.gforce_current = round(max(A.gforce_minimum, global.zlevels[src.z].gforce + A.gforce_tether + src.gforce_inherent), 0.01)
