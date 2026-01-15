ABSTRACT_TYPE(/datum/spatial_hashmap)
/**
 *	Spatial hashmaps partition the game world into cells, with each cell spanning a square area of turfs. Entries registered to
 *	the hashmap will be placed in the cell corresponding to their position; this allows for the efficient querying of hashmap
 *	entries near a point on the map.
 *
 *	Hashmap entries do not necessarily require to be atoms with a physical position to be registered to the hashmap, nor do
 *	atoms require to be represented by their own map position; instead another atom may be used to represent an entry's physical
 *	position.
 */
/datum/spatial_hashmap
	/// The debug name of this spatial hashmap.
	var/name = null

	/**
	 *	A 3D grid of associative lists representing each cell of the hashmap, indexed by their 3D spatial axes. \
	 *	The hashmap is defined in the following way:
	 *	> `hashmap[z][y][x] = alist(E₁, E₂, ..., Eᵢ)`
	 *
	 *	Where `{E₁, E₂, ..., Eᵢ}` are the hashmap entries contained within the grid cell at `(x, y, z)`.
	 *	Note that these coordinates are in grid space, not world space.
	 *
	 *	Grid cells are represented by associative lists so to prevent accidental entry duplication. Each hashmap entry is
	 *	associated with a null value.
	 */
	VAR_PROTECTED/list/list/list/alist/hashmap = null

	/**
	 *	An associative list of atoms being using to represent physical positions, and their associated signal subscription count. \
	 *	Type structure: `/alist</atom, int>`
	 */
	VAR_PROTECTED/alist/tracked_atoms_with_subcount = null
	/**
	 *	An associative list of atoms, indexed by the hashmap entry using them to represent a physical position. \
	 *	Type structure: `/alist</datum, /atom>`
	 */
	VAR_PROTECTED/alist/atoms_by_entry = null
	/**
	 *	An associative list of lists of hashmap entries, indexed by the atom being used to represent a physical position. \
	 *	Type structure: `/alist</atom, /list/datum>`
	 */
	VAR_PROTECTED/alist/entries_by_atom = null

	/// The size of each cell in the hashmap. For example, a cell size of 30 would result in a 300x300 map being reduced to a 10x10 hashmap.
	VAR_PROTECTED/cell_size = 30
	/// The x-component of the order of the hashmap, i.e. the number of cells in the x-direction.
	VAR_PROTECTED/x_order = null
	/// The y-component of the order of the hashmap, i.e. the number of cells in the y-direction.
	VAR_PROTECTED/y_order = null
	/// The z-component of the order of the hashmap, i.e. the number of cells in the z-direction.
	VAR_PROTECTED/z_order = null

/datum/spatial_hashmap/New(width = world.maxx, height = world.maxy, depth = world.maxz, cell_size, name)
	. = ..()
	START_TRACKING

	width = clamp(width, 0, world.maxx)
	height = clamp(height, 0, world.maxy)
	depth = clamp(depth, 0, world.maxz)

	if (!isnull(cell_size))
		src.cell_size = cell_size

	src.x_order = ceil(width / src.cell_size)
	src.y_order = ceil(height / src.cell_size)
	src.z_order = depth
	src.name = name

	src.hashmap = new /list(src.z_order, src.y_order, src.x_order)
	for (var/z in 1 to src.z_order)
		for (var/y in 1 to src.y_order)
			for (var/x in 1 to src.x_order)
				src.hashmap[z][y][x] = alist()

	src.tracked_atoms_with_subcount = alist()
	src.atoms_by_entry = alist()
	src.entries_by_atom = alist()

/datum/spatial_hashmap/disposing()
	for (var/datum/entry as anything in src.atoms_by_entry)
		src.unregister_hashmap_entry(entry)

	src.hashmap = null
	src.tracked_atoms_with_subcount = null
	src.atoms_by_entry = null
	src.entries_by_atom = null

	STOP_TRACKING
	. = ..()

/**
 *	Forms a diamond of size `range` around the point `(T.x, T.y)` on the `T.z` layer of the hashmap, and returns the concatenated
 *	contents of the cells that contain points within that diamond.
 *
 *	Termed "fast" because it only considers ranges less than or equal to that of the hashmap's cell size.
 */
/datum/spatial_hashmap/proc/fast_manhattan(turf/T, range = 30)
	RETURN_TYPE(/alist)
	. = alist()

	if (!T?.z || (T.z > src.z_order))
		return

	var/alist/cells = alist()
	var/list/list/alist/hashmap_slice = src.hashmap[T.z]

	// If the range is greater than the cell size, the some cells may be jumped over by the code below.
	range = min(range, src.cell_size)

	// Add the cell corresponding to the `(T.x, T.y, T.z)` point.
	var/grid_x = ceil(T.x / src.cell_size)
	var/grid_y = ceil(T.y / src.cell_size)
	cells[hashmap_slice[grid_y][grid_x]] = null

	// Add the cells corresponding to the position plus the range, applied in each cardinal direction.
	var/min_x = max(ceil((T.x - range) / src.cell_size), 1)
	var/max_x = min(ceil((T.x + range) / src.cell_size), src.x_order)
	var/min_y = max(ceil((T.y - range) / src.cell_size), 1)
	var/max_y = min(ceil((T.y + range) / src.cell_size), src.y_order)
	cells[hashmap_slice[max_y][grid_x]] = null // North
	cells[hashmap_slice[grid_y][max_x]] = null // East
	cells[hashmap_slice[min_y][grid_x]] = null // South
	cells[hashmap_slice[grid_y][min_x]] = null // West

	// Add the cells corresponding to the position plus the scaled range, applied in each ordinal direction.
	var/scaled_range = range * 0.5
	var/min_scaled_x = max(ceil((T.x - scaled_range) / src.cell_size), 1)
	var/max_scaled_x = min(ceil((T.x + scaled_range) / src.cell_size), src.x_order)
	var/min_scaled_y = max(ceil((T.y - scaled_range) / src.cell_size), 1)
	var/max_scaled_y = min(ceil((T.y + scaled_range) / src.cell_size), src.y_order)
	cells[hashmap_slice[max_scaled_y][max_scaled_x]] = null // Northeast
	cells[hashmap_slice[min_scaled_y][max_scaled_x]] = null // Southeast
	cells[hashmap_slice[min_scaled_y][min_scaled_x]] = null // Southwest
	cells[hashmap_slice[max_scaled_y][min_scaled_x]] = null // Northwest

	// Concatenate the contents of each cell into a single list.
	for (var/alist/cell as anything in cells)
		. += cell

/**
 *	Forms a square of size `range` around the point `(T.x, T.y)` on the `T.z` layer of the hashmap, and returns the concatenated
 *	contents of the cells that contain points within that square.
 */
/datum/spatial_hashmap/proc/supremum(turf/T, range = 30)
	RETURN_TYPE(/alist)
	. = alist()

	if (!T?.z || (T.z > src.z_order))
		return

	var/list/list/alist/hashmap_slice = src.hashmap[T.z]

	// Locate any cells that contain points within `range` of the point `(T.x, T.y, T.z)`.
	var/min_x = max(ceil((T.x - range) / src.cell_size), 1)
	var/max_x = min(ceil((T.x + range) / src.cell_size), src.x_order)
	var/min_y = max(ceil((T.y - range) / src.cell_size), 1)
	var/max_y = min(ceil((T.y + range) / src.cell_size), src.y_order)

	for (var/i in min_y to max_y)
		for (var/j in min_x to max_x)
			. += hashmap_slice[i][j]

/**
 *	Forms a square of size `range` around the point `(T.x, T.y)` on the `T.z` layer of the hashmap, and returns the concatenated
 *	contents of the cells that contain points within that square.
 *
 *	If present, takes into consideration the vistarget of the turf for range calculations.
 */
/datum/spatial_hashmap/proc/vistarget_supremum(turf/T, range = 30)
	RETURN_TYPE(/alist)
	. = alist()

	if (!T)
		return

	if (!T.vistarget)
		return src.supremum(T, range)

	var/alist/cells = alist()

	// Locate any cells that contain points within `range` of the point `(T.x, T.y, T.z)`.
	if (T.z && (T.z <= src.z_order))
		var/list/list/alist/hashmap_slice = src.hashmap[T.z]

		var/min_x = max(ceil((T.x - range) / src.cell_size), 1)
		var/max_x = min(ceil((T.x + range) / src.cell_size), src.x_order)
		var/min_y = max(ceil((T.y - range) / src.cell_size), 1)
		var/max_y = min(ceil((T.y + range) / src.cell_size), src.y_order)

		for (var/i in min_y to max_y)
			for (var/j in min_x to max_x)
				cells[hashmap_slice[i][j]] = null

	// Locate any cells that contain points within `range` of the point `(T.vistarget.x, T.vistarget.y, T.vistarget.z)`.
	T = T.vistarget
	if (T.z && (T.z <= src.z_order))
		var/list/list/alist/hashmap_slice = src.hashmap[T.z]

		var/min_x = max(ceil((T.x - range) / src.cell_size), 1)
		var/max_x = min(ceil((T.x + range) / src.cell_size), src.x_order)
		var/min_y = max(ceil((T.y - range) / src.cell_size), 1)
		var/max_y = min(ceil((T.y + range) / src.cell_size), src.y_order)

		for (var/i in min_y to max_y)
			for (var/j in min_x to max_x)
				cells[hashmap_slice[i][j]] = null

	// Concatenate the contents of each cell into a single list.
	for (var/alist/cell as anything in cells)
		. += cell

/**
 *	Forms a square of size `range` around the point `(T.x, T.y)` on the `T.z` layer of the hashmap, and returns all the hashmap
 *	entries within that square.
 */
/datum/spatial_hashmap/proc/exact_supremum(turf/T, range = 30)
	RETURN_TYPE(/alist)
	. = src.supremum(T, range)

	// Iterate through each entry and cull any entries that exist outside of the range.
	for (var/datum/entry as anything in .)
		var/turf/position = get_turf(src.atoms_by_entry[entry])
		if (max(abs(position.x - T.x), abs(position.y - T.y)) <= range)
			continue

		. -= entry

/**
 *	Returns the contents of the cell that contains the `(T.x, T.y)` point on the `T.z` layer of the hashmap.
 */
/datum/spatial_hashmap/proc/point(turf/T)
	RETURN_TYPE(/alist)
	. = alist()

	if (!T?.z || (T.z > src.z_order))
		return

	// Return the cell corresponding to the `(T.x, T.y, T.z)` point.
	// A new alist is created so that the hashmap isn't exposed by directly returning the cell alist.
	var/grid_x = ceil(T.x / src.cell_size)
	var/grid_y = ceil(T.y / src.cell_size)
	. += src.hashmap[T.z][grid_y][grid_x]

/**
 *	Returns the contents of the cell that contains the `(T.x, T.y)` point on the `T.z` layer of the hashmap.
 *
 *	If present, takes into consideration the vistarget of the turf as a second point.
 */
/datum/spatial_hashmap/proc/vistarget_point(turf/T)
	RETURN_TYPE(/alist)
	. = alist()

	if (!T)
		return

	if (!T.vistarget)
		return src.point(T)

	var/alist/cells = alist()

	// Add the cell corresponding to the `(T.x, T.y, T.z)` point.
	if (T.z && (T.z <= src.z_order))
		var/grid_x = ceil(T.x / src.cell_size)
		var/grid_y = ceil(T.y / src.cell_size)
		cells[src.hashmap[T.z][grid_y][grid_x]] = null

	// Add the cell corresponding to the `(T.vistarget.x, T.vistarget.y, T.vistarget.z)` point.
	T = T.vistarget
	if (T.z && (T.z <= src.z_order))
		var/grid_x = ceil(T.x / src.cell_size)
		var/grid_y = ceil(T.y / src.cell_size)
		cells[src.hashmap[T.z][grid_y][grid_x]] = null

	// Concatenate the contents of each cell into a single list.
	for (var/alist/cell as anything in cells)
		. += cell

/**
 *	Adds an entry to the hashmap using a tracked atom representing the entry's physical position.
 *	If `entry` is an atom and no `tracked_atom` is passed, `entry` will be used in its place.
 */
/datum/spatial_hashmap/proc/register_hashmap_entry(datum/entry, atom/tracked_atom)
	if (src.atoms_by_entry[entry])
		return

	tracked_atom ||= entry
	if (!istype(tracked_atom))
		return

	// Increment a tracked atom's signal subscription count.
	if (!src.tracked_atoms_with_subcount[tracked_atom])
		src.tracked_atoms_with_subcount[tracked_atom] = 1
		src.RegisterSignal(tracked_atom, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(update_entry))
	else
		src.tracked_atoms_with_subcount[tracked_atom] += 1

	// Associate the hashmap entry with the tracked atom and vice versa.
	src.atoms_by_entry[entry] = tracked_atom
	src.entries_by_atom[tracked_atom] ||= list()
	src.entries_by_atom[tracked_atom] += entry

	// Provided the tracked atom isn't in nullspace, add it to the hashmap data structure.
	var/turf/T = get_turf(tracked_atom)
	if (T)
		var/x = ceil(T.x / src.cell_size)
		var/y = ceil(T.y / src.cell_size)
		var/z = T.z
		if (z && (z <= src.z_order))
			src.hashmap[z][y][x] += entry

/**
 *	Removes an entry from the hashmap.
 */
/datum/spatial_hashmap/proc/unregister_hashmap_entry(datum/entry)
	var/atom/tracked_atom = src.atoms_by_entry[entry]
	if (!istype(tracked_atom))
		return

	// Decrement a tracked atom's signal subscription count.
	src.tracked_atoms_with_subcount[tracked_atom] -= 1
	if (!src.tracked_atoms_with_subcount[tracked_atom])
		src.tracked_atoms_with_subcount -= tracked_atom
		src.UnregisterSignal(tracked_atom, XSIG_MOVABLE_TURF_CHANGED)

	// Dissociate the hashmap entry with the tracked atom and vice versa.
	src.atoms_by_entry -= entry
	src.entries_by_atom[tracked_atom] -= entry
	if (!length(src.entries_by_atom[tracked_atom]))
		src.entries_by_atom -= tracked_atom

	// Provided the tracked atom isn't in nullspace, remove it from the hashmap data structure.
	var/turf/T = get_turf(tracked_atom)
	if (T)
		var/x = ceil(T.x / src.cell_size)
		var/y = ceil(T.y / src.cell_size)
		var/z = T.z
		if (z && (z <= src.z_order))
			src.hashmap[z][y][x] -= entry

/**
 *	Updates the tracked atom being used to represent the physical position of a hashmap entry.
 */
/datum/spatial_hashmap/proc/update_tracked_atom(datum/entry, atom/new_tracked_atom)
	src.unregister_hashmap_entry(entry)
	src.register_hashmap_entry(entry, new_tracked_atom)

/**
 *	Updates the position of a hashmap entry.
 *	Internal use only.
 */
/datum/spatial_hashmap/proc/update_entry(datum/component/complexsignal/outermost_movable/component, turf/old_turf, turf/new_turf)
	if (old_turf && new_turf)
		var/old_x = ceil(old_turf.x / src.cell_size)
		var/new_x = ceil(new_turf.x / src.cell_size)
		var/old_y = ceil(old_turf.y / src.cell_size)
		var/new_y = ceil(new_turf.y / src.cell_size)

		if ((old_x == new_x) && (old_y == new_y))
			return

		if (old_turf.z && (old_turf.z <= src.z_order))
			src.hashmap[old_turf.z][old_y][old_x] -= src.entries_by_atom[component.parent]
		if (new_turf.z && (new_turf.z <= src.z_order))
			src.hashmap[new_turf.z][new_y][new_x] += src.entries_by_atom[component.parent]

	else if (old_turf?.z && (old_turf.z <= src.z_order))
		var/old_x = ceil(old_turf.x / src.cell_size)
		var/old_y = ceil(old_turf.y / src.cell_size)
		src.hashmap[old_turf.z][old_y][old_x] -= src.entries_by_atom[component.parent]

	else if (new_turf?.z && (new_turf.z <= src.z_order))
		var/new_x = ceil(new_turf.x / src.cell_size)
		var/new_y = ceil(new_turf.y / src.cell_size)
		src.hashmap[new_turf.z][new_y][new_x] += src.entries_by_atom[component.parent]
