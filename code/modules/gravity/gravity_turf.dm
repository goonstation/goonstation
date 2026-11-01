/// current gforce on this turf
/turf/var/gforce_current = GFORCE_EARTH_GRAVITY
/// gforce inherent to the turf tile, e.g. asteroids and airbridges
/turf/var/gforce_inherent = GFORCE_GRAVITY_MINIMUM
/// Used to check if we need to recalculate gforces. If less than the area's gforce_rev, update required.
/turf/var/gforce_area_rev = 0
/turf/var/gforce_override = null

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

/turf/proc/set_gforce_override(new_gforce)
	src.gforce_override = new_gforce
	src.gforce_area_rev = 0
	src.get_gforce_current()

/turf/proc/clear_gforce_override()
	src.gforce_override = null
	src.gforce_area_rev = 0
	src.get_gforce_current()

/turf/proc/get_gforce_current()
	var/area/A = src.loc
	if (A.gforce_rev > src.gforce_area_rev)
		if (!isnull(src.gforce_override)) // it can be 0
			src.gforce_current = src.gforce_override
		else
			src.gforce_current = max(A.gforce_minimum, global.zlevels[src.z].gforce + A.gforce_tether, src.gforce_inherent)
		src.gforce_area_rev = A.gforce_rev
	return src.gforce_current

/turf/space/get_gforce_current()
	return GFORCE_GRAVITY_MINIMUM

/turf/space/fluid/get_gforce_current()
	var/area/A = src.loc
	if (A.gforce_rev > src.gforce_area_rev)
		if (!isnull(src.gforce_override)) // it can be 0
			src.gforce_current = src.gforce_override
		else
			src.gforce_current = max(A.gforce_minimum, global.zlevels[src.z].gforce + A.gforce_tether, src.gforce_inherent)
		src.gforce_area_rev = A.gforce_rev
	return src.gforce_current

/turf/proc/get_gforce_fractional()
	. = src.get_gforce_current() / GFORCE_EARTH_GRAVITY

/turf/setMaterial(datum/material/mat1, appearance, setname, mutable, use_descriptors)
	. = ..()
	if (contains_negative_matter(src))
		src.set_gforce_override(0) // *always* zero-G
	else if (src.gforce_override)
		src.clear_gforce_override()

/datum/infooverlay/gravity_turf
	name = "gravity"
	help = {"Colors group mob gravity thresholds. Dirty cache marked with *."}
	var/list/area/processed_areas

	GetInfo(turf/theTurf, image/debugoverlay/img)
		var/area/A = get_area(theTurf)
		img.app.overlays = list(src.makeText("[theTurf.gforce_current/GFORCE_EARTH_GRAVITY]G[theTurf.gforce_area_rev < A.gforce_rev ? "*" : ""]", RESET_ALPHA | RESET_COLOR))
		switch (theTurf.gforce_current)
			if (-INFINITY to GFORCE_GRAVITY_MINIMUM)
				img.app.color = "#fde725"
			if (GFORCE_MOB_REGULAR_THRESHOLD to GFORCE_EARTH_GRAVITY)
				img.app.color = "#5ec962"
			if (GFORCE_GRAVITY_MINIMUM to GFORCE_MOB_REGULAR_THRESHOLD)
				img.app.color = "#addc30"
			if (GFORCE_MOB_PANCAKE_THRESHOLD to INFINITY)
				img.app.color = "#440154"
			if (GFORCE_MOB_BLINDNESS_THRESHOLD to GFORCE_MOB_PANCAKE_THRESHOLD)
				img.app.color = "#472d7b"
			if (GFORCE_MOB_TUNNEL_VISION_THRESHOLD to GFORCE_MOB_BLINDNESS_THRESHOLD)
				img.app.color = "#3b528b"
			if (GFORCE_MOB_GREYOUT_THRESHOLD to GFORCE_MOB_TUNNEL_VISION_THRESHOLD)
				img.app.color = "#2c728e"
			if (GFORCE_MOB_EXTREME_THRESHOLD to GFORCE_MOB_GREYOUT_THRESHOLD)
				img.app.color = "#21918c"
			if (GFORCE_MOB_HIGH_THRESHOLD to GFORCE_MOB_EXTREME_THRESHOLD)
				img.app.color = "#28ae80"
			if (GFORCE_EARTH_GRAVITY to GFORCE_MOB_HIGH_THRESHOLD)
				img.app.color = "#5ec962"
