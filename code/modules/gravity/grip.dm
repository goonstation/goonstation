/// Total number of atoms providing grip on this turf
///
/// This is used  to determine if the turf can provide grip.
/turf/var/grip_atom_count = 0

// walls always grippable
/turf/simulated/wall/grip_atom_count = 1
/turf/unsimulated/wall/grip_atom_count = 1

//TODO: Remove compatibilty patch after secret update
/atom/var/stops_space_move = FALSE
/turf/simulated/floor/stops_space_move = TRUE
/turf/simulated/wall/stops_space_move = TRUE
/obj/lattice/stops_space_move = TRUE

/// Get a live count of the number of grippable objects
/turf/proc/calculate_grippy_objects()
	. = 0
	if (src.provides_grip)
		. += 1
	for (var/atom/movable/AM as anything in src.contents)
		if (AM.provides_grip)
			. += 1

/// Actually sets the turf's grippy value
/turf/proc/reset_grippy_objects()
	src.grip_atom_count = src.calculate_grippy_objects()

/// Check if an atom could grip something on a nearby tile, such as a wall or table
/atom/movable/proc/has_grip()
	var/turf/my_turf = src.loc
	if (!istype(my_turf)) // inside something
		return TRUE
	if (my_turf.grip_atom_count > 0)
		return TRUE
	for (var/dir in alldirs)
		var/turf/neighbor = get_turf(get_step(src, dir))
		if (neighbor?.grip_atom_count > 0)
			return TRUE
	return FALSE

/datum/infooverlay/grip_info
	name = "grip-info"
	help = "Green: grippable; Yellow: not grippable"

	GetInfo(turf/theTurf, image/debugoverlay/img)
		img.app.overlays = list(src.makeText("[theTurf.grip_atom_count]", RESET_ALPHA | RESET_COLOR))
		if (theTurf.grip_atom_count == 0)
			img.app.color = "#990"
			return ..()
		img.app.color = "#0c0"
		return ..()

/datum/infooverlay/grip_debug
	name = "grip-debug"
	help = "Red: cache mismatch; Green: grippable; Yellow: not grippable; Actual (cached)"

	GetInfo(turf/theTurf, image/debugoverlay/img)
		var/actual_count = theTurf.calculate_grippy_objects()

		if (theTurf.grip_atom_count != actual_count)
			img.app.overlays = list(src.makeText("[actual_count] ([theTurf.grip_atom_count])", RESET_ALPHA | RESET_COLOR))
			img.app.color = "#f00"
			return ..()
		img.app.overlays = list(src.makeText("[actual_count]", RESET_ALPHA | RESET_COLOR))
		if (actual_count == 0)
			img.app.color = "#990"
			return ..()
		img.app.color = "#0c0"
		return ..()

