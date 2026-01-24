/// current gforce on this turf
/turf/var/gforce_current = GFORCE_EARTH_GRAVITY
/// gforce inherent to the turf tile, e.g. asteroids and airbridges
/turf/var/gforce_inherent = GFORCE_GRAVITY_MINIMUM
/// Used to check if we need to recalculate gforces. If less than the area's gforce_rev, update required.
/turf/var/gforce_area_rev = 0

// no gravity in space, we never need to update it
/turf/space/gforce_current = GFORCE_GRAVITY_MINIMUM
/turf/space/gforce_area_rev = INFINITY

/turf/unsimulated/floor/gforce_inherent = GFORCE_EARTH_GRAVITY
/turf/unsimulated/wall/gforce_inherent = GFORCE_EARTH_GRAVITY

// ocean gravity handled at zlevel, so these need to track area revs
/turf/space/fluid/gforce_area_rev = 0

/turf/proc/change_gforce_inherent(gforce_diff)
	src.gforce_inherent += gforce_diff
	src.gforce_area_rev = 0

/turf/proc/set_gforce_inherent(new_gforce)
	src.gforce_inherent = new_gforce
	src.gforce_area_rev = 0

/turf/proc/get_gforce_current()
	var/area/A = src.loc
	if (A.gforce_rev > src.gforce_area_rev)
		src.gforce_current = max(A.gforce_minimum, global.zlevels[src.z].gforce + A.gforce_tether, src.gforce_inherent)
		src.gforce_area_rev = A.gforce_rev
	return src.gforce_current

/turf/space/get_gforce_current()
	return GFORCE_GRAVITY_MINIMUM

/turf/space/fluid/get_gforce_current()
	var/area/A = src.loc
	if (A.gforce_rev > src.gforce_area_rev)
		src.gforce_current = max(A.gforce_minimum, global.zlevels[src.z].gforce + A.gforce_tether, src.gforce_inherent)
		src.gforce_area_rev = A.gforce_rev
	return src.gforce_current

/turf/proc/get_gforce_fractional()
	. = src.get_gforce_current() / GFORCE_EARTH_GRAVITY

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
	name = "gravity"
	help = {"Colors group mob gravity thresholds. Dirty cache marked with *."}
	var/list/area/processed_areas

	GetInfo(turf/theTurf, image/debugoverlay/img)
		var/area/A = get_area(theTurf)
		img.app.overlays = list(src.makeText("[theTurf.gforce_current][theTurf.gforce_area_rev < A.gforce_rev ? "*" : ""]", RESET_ALPHA | RESET_COLOR))
		switch (theTurf.gforce_current)
			if (-INFINITY to GFORCE_GRAVITY_MINIMUM)
				img.app.color = "#909"
			if (GFORCE_MOB_REGULAR_THRESHOLD to GFORCE_EARTH_GRAVITY)
				img.app.color = "#0f0"
			if (GFORCE_GRAVITY_MINIMUM to GFORCE_MOB_REGULAR_THRESHOLD)
				img.app.color = "#0aa"
			if (GFORCE_MOB_PANCAKE_THRESHOLD to INFINITY)
				img.app.color = "#f00"
			if (GFORCE_MOB_BLINDNESS_THRESHOLD to GFORCE_MOB_PANCAKE_THRESHOLD)
				img.app.color = "#000"
			if (GFORCE_MOB_TUNNEL_VISION_THRESHOLD to GFORCE_MOB_BLINDNESS_THRESHOLD)
				img.app.color = "#666"
			if (GFORCE_MOB_GREYOUT_THRESHOLD to GFORCE_MOB_TUNNEL_VISION_THRESHOLD)
				img.app.color = "#999"
			if (GFORCE_MOB_EXTREME_THRESHOLD to GFORCE_MOB_GREYOUT_THRESHOLD)
				img.app.color = "#fa0"
			if (GFORCE_MOB_HIGH_THRESHOLD to GFORCE_MOB_EXTREME_THRESHOLD)
				img.app.color = "#ff0"
			if (GFORCE_EARTH_GRAVITY to GFORCE_MOB_HIGH_THRESHOLD)
				img.app.color = "#0f0"
