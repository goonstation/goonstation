/// current gforce on this turf
/turf/var/gforce_current = 1
/// gforce inherent to the turf tile, e.g. asteroids and airbridges
/turf/var/gforce_inherent = 0
/// Used to check if we need to recalculate gforces. If less than the area's gforce_rev, update required.
/turf/var/gforce_area_rev = 0

// no gravity in space
/turf/space/gforce_current = 0
/turf/space/gforce_inherent = 0

// ocean gravity handled at zlevel
/turf/space/fluid/gforce_current = 1
/turf/space/fluid/gforce_inherent = 0

/turf/proc/change_gforce_inherent(gforce_diff)
/turf/simulated/change_gforce_inherent(gforce_diff)
	src.gforce_inherent += gforce_diff
	src.gforce_area_rev = 0

/turf/proc/set_gforce_inherent(new_gforce)
/turf/simulated/set_gforce_inherent(new_gforce)
	src.gforce_inherent = new_gforce
	src.gforce_area_rev = 0

/turf/proc/get_gforce_current()
	var/area/A = src.loc
	if (A.gforce_rev > src.gforce_area_rev)
		src.gforce_current = round(max(A.gforce_minimum, global.zlevels[src.z].gforce + A.gforce_tether + src.gforce_inherent), 0.01)
		src.gforce_area_rev = A.gforce_rev
	return src.gforce_current

// asteroids have enough G for some traction (for mining)
/turf/simulated/wall/auto/asteroid/gforce_inherent = GFORCE_TRACTION_PARTIAL
/turf/unsimulated/floor/plating/asteroid/gforce_inherent = GFORCE_TRACTION_PARTIAL
/turf/simulated/floor/plating/airless/asteroid/gforce_inherent = GFORCE_TRACTION_PARTIAL

/turf/setMaterial(datum/material/mat1, appearance, setname, mutable, use_descriptors)
	. = ..()
	if (contains_negative_matter(src))
		src.set_gforce_inherent(-INFINITY) // *always* zero-G
	else if (src.gforce_inherent != initial(src.gforce_inherent))
		// This could be buggy, but storing it feels wasteful. How much stuff gets *un*-negatived?
		src.set_gforce_inherent(initial(src.gforce_inherent))

/datum/infooverlay/gravity_turf
	name = "gravity-turf"
	help = {"Colors group mob gravity thresholds. Dirty cache marked with *."}
	var/list/area/processed_areas

	GetInfo(turf/theTurf, image/debugoverlay/img)
		var/area/A = get_area(theTurf)
		img.app.overlays = list(src.makeText("[theTurf.gforce_current][theTurf.gforce_area_rev < A.gforce_rev ? "*" : ""]", RESET_ALPHA | RESET_COLOR))
		switch (theTurf.gforce_current)
			if (-INFINITY to 0)
				img.app.color = "#0000ff"
			if (1)
				img.app.color = "#00ff00"
			if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
				img.app.color = "#00aaaa"
			if (GRAVITY_MOB_REGULAR_THRESHOLD to GRAVITY_MOB_HIGH_THRESHOLD)
				img.app.color = "#009900"
			if (GRAVITY_MOB_HIGH_THRESHOLD to GRAVITY_MOB_EXTREME_THRESHOLD)
				img.app.color = "#cc9900"
			if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
				img.app.color = "#ff0000"
