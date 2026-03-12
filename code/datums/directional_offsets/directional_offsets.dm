ABSTRACT_TYPE(/datum/directional_offsets)
/datum/directional_offsets
	/// The non-unique ID of this directional offset datum. Corresponds to the name of the offsets tuple.
	var/id = null
	/// If several directional offset datums are defined for a single ID, datums with a higher priority will be considered for use first.
	var/priority = 0
	/// The `pixel_x` offset that an object should use when facing NORTH.
	var/nx = 0
	/// The `pixel_y` offset that an object should use when facing NORTH.
	var/ny = 0
	/// The `pixel_x` offset that an object should use when facing EAST.
	var/ex = 0
	/// The `pixel_y` offset that an object should use when facing EAST.
	var/ey = 0
	/// The `pixel_x` offset that an object should use when facing SOUTH.
	var/sx = 0
	/// The `pixel_y` offset that an object should use when facing SOUTH.
	var/sy = 0
	/// The `pixel_x` offset that an object should use when facing WEST.
	var/wx = 0
	/// The `pixel_y` offset that an object should use when facing WEST.
	var/wy = 0

/// Whether this directional offsets datum can be used with the atom and direction.
/datum/directional_offsets/proc/is_compatible(atom/A, old_dir, new_dir)
	return TRUE

/// Apply this directional offsets datum's offsets to an atom.
/datum/directional_offsets/proc/apply_offsets(datum/component/directional/C, atom/A, old_dir, new_dir)
	switch (new_dir)
		if (NORTH)
			A.pixel_x = src.nx
			A.pixel_y = src.ny

		if (EAST)
			A.pixel_x = src.ex
			A.pixel_y = src.ey

		if (SOUTH)
			A.pixel_x = src.sx
			A.pixel_y = src.sy

		if (WEST)
			A.pixel_x = src.wx
			A.pixel_y = src.wy

	A.pixel_x += C.initial_x_offset
	A.pixel_y += C.initial_y_offset


ABSTRACT_TYPE(/datum/directional_offsets/standard)
/datum/directional_offsets/standard
	priority = 0


ABSTRACT_TYPE(/datum/directional_offsets/jen_walls)
/datum/directional_offsets/jen_walls
	priority = 1

/datum/directional_offsets/jen_walls/is_compatible(atom/A, old_dir, new_dir)
	var/turf/T = get_step(A, A.dir)
	if (istype(T, /turf/simulated/wall/auto/jen) || istype(T, /turf/simulated/wall/auto/reinforced/jen))
		return TRUE

	return FALSE
